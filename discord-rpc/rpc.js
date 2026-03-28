const { app, Tray, Menu, nativeImage, dialog } = require('electron')
const path = require('path')
const http = require('http')
const os = require('os')
const { execSync } = require('child_process')
const DiscordRPC = require('discord-rpc')
const express = require('express')

const CLIENT_ID = '1339738380581470380'
const PORT = 5001

DiscordRPC.register(CLIENT_ID)

let rpc = null
let rpcConnected = false
let rpcEnabled = true
let currentMedia = null
let tray = null
let discordAlertShown = false

function getLocalIP() {
    const interfaces = os.networkInterfaces()
    const priority = ['en0', 'en1', 'wlan0']

    for (const name of priority) {
        const ifaceList = interfaces[name]
        if (!ifaceList) continue
        for (const iface of ifaceList) {
            if (iface.family === 'IPv4' && !iface.internal) return iface.address
        }
    }

    for (const name of Object.keys(interfaces)) {
        for (const iface of interfaces[name]) {
            if (iface.family === 'IPv4' && !iface.internal) return iface.address
        }
    }

    return '127.0.0.1'
}

function freePort(port) {
    try {
        if (process.platform === 'win32') {
            const result = execSync(`netstat -ano | findstr :${port}`).toString()
            const lines = result.trim().split('\n')
            const pids = new Set()
            for (const line of lines) {
                const parts = line.trim().split(/\s+/)
                const pid = parts[parts.length - 1]
                if (pid && pid !== String(process.pid)) pids.add(pid)
            }
            for (const pid of pids) {
                execSync(`taskkill /PID ${pid} /F`)
            }
        } else {
            const result = execSync(`lsof -ti :${port}`).toString().trim()
            if (result) {
                const pids = result.split('\n').filter(p => p !== String(process.pid))
                if (pids.length) execSync(`kill -9 ${pids.join(' ')}`)
            }
        }
        console.log(`Port ${port} freed`)
    } catch (e) { }
}

function createRPC() {
    if (rpc) {
        rpc.destroy().catch(() => {})
    }
    rpc = new DiscordRPC.Client({ transport: 'ipc' })
    rpc.on('disconnected', () => {
        rpcConnected = false
        console.log('Discord RPC disconnected, retrying in 10 sec')
        refreshTray()
        setTimeout(connectRPC, 10000)
    })
}

async function connectRPC() {
    createRPC()
    try {
        await rpc.login({ clientId: CLIENT_ID })
        rpcConnected = true
        discordAlertShown = false
        console.log('Discord RPC connected')
        refreshTray()
    } catch (e) {
        console.log('Retrying in 10 sec –', e.message)

        if (!discordAlertShown) {
            discordAlertShown = true
            dialog.showMessageBox({
                type: 'warning',
                title: 'YouTube Plus RPC',
                message: 'Discord is not running',
                detail: 'Please launch Discord and the app will connect automatically.',
                buttons: ['OK']
            })
        }

        setTimeout(connectRPC, 10000)
    }
}

async function updatePresence(media) {
    if (!rpcConnected || !media || !rpcEnabled) return

    const now = Math.floor(Date.now() / 1000)
    const startedAt = now - Math.floor(media.currentTime)
    const endsAt = startedAt + Math.floor(media.totalTime)

    try {
        if (media.state === 'stopped') {
            await rpc.clearActivity()
            console.log('Presence cleared')
            refreshTray()
            return
        }

        const isPlaying = media.state === 'playing'

        const activity = {
            type: 3,
            details: media.title?.slice(0, 128),
            state: media.channel?.slice(0, 128) || undefined,
            assets: {
                large_image: media.thumbnailUrl || 'youtube_logo',
                large_text: media.title?.slice(0, 128),
                small_image: isPlaying ? 'play' : 'pause',
                small_text: isPlaying ? 'Playing' : 'Paused',
            },
            timestamps: isPlaying && media.totalTime > 0 ? {
                start: startedAt,
                end: endsAt
            } : undefined,
            buttons: media.videoId ? [
                { label: 'Watch on YouTube', url: `https://youtu.be/${media.videoId}` }
            ] : undefined,
        }

        await rpc.request('SET_ACTIVITY', { pid: process.pid, activity })
        console.log(`[${media.state}] ${media.title} — ${media.channel} (${Math.floor(media.currentTime)}s / ${Math.floor(media.totalTime)}s)`)
        refreshTray()
    } catch (e) {
        console.error('RPC error:', e.message)
    }
}

function refreshTray() {
    if (!tray) return
    tray.setContextMenu(buildMenu())
}

function buildMenu() {
    const title = currentMedia?.title
    const truncated = title ? (title.length > 32 ? title.slice(0, 32) + '…' : title) : null
    const localIP = getLocalIP()

    return Menu.buildFromTemplate([
        { label: 'YouTube Plus RPC', enabled: false },
        { type: 'separator' },
        { label: rpcConnected ? 'Discord connected 🟢' : 'Discord disconnected 🔴', enabled: false },
        { label: truncated ? `▶ ${truncated}` : 'Nothing playing', enabled: false },
        { type: 'separator' },
        {
            label: 'Display in profile',
            type: 'checkbox',
            checked: rpcEnabled,
            click: (item) => {
                rpcEnabled = item.checked
                if (!rpcEnabled) rpc.clearActivity().catch(() => {})
                refreshTray()
            }
        },
        { type: 'separator' },
        { label: `Server: http://${localIP}:${PORT}`, enabled: false },
        { type: 'separator' },
        { label: 'v1.0.0', enabled: false },
        { type: 'separator' },
        { label: 'Quit', click: () => app.quit() }
    ])
}

const expressApp = express()
expressApp.use(express.json())

const last = { title: null, currentTime: 0, time: 0 }

expressApp.post('/update', async (req, res) => {
    const data = req.body
    const now = Date.now()

    if (data.state === 'playing' &&
        data.title === last.title &&
        data.current_time === last.currentTime &&
        now - last.time < 1000) {
        return res.json({ ok: true, skipped: true })
    }

    last.title = data.title
    last.currentTime = data.current_time
    last.time = now

    currentMedia = {
        title: data.title || 'Unknown video',
        channel: data.channel || '',
        state: data.state || 'playing',
        videoId: data.video_id || '',
        thumbnailUrl: data.thumbnail_url || '',
        currentTime: data.current_time || 0,
        totalTime: data.total_time || 0,
    }

    await updatePresence(currentMedia)
    res.json({ ok: true })
})

expressApp.get('/health', (req, res) => {
    res.json({ ok: true, rpc: rpcConnected, enabled: rpcEnabled })
})

app.whenReady().then(async () => {
    app.dock?.hide()

    freePort(PORT)

    const localIP = getLocalIP()

    http.createServer(expressApp).listen(PORT, '0.0.0.0', () => {
        console.log(`HTTP server available at http://${localIP}:${PORT}`)
    })

    const icon = nativeImage.createFromPath(path.join(__dirname, 'assets/icon.png'))
    const resized = icon.resize({ width: 16, height: 16 })
    tray = new Tray(resized)
    tray.setToolTip('YouTube RPC')
    tray.setContextMenu(buildMenu())

    await connectRPC()
})

app.on('window-all-closed', (e) => e.preventDefault())