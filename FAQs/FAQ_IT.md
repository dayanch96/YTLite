# FAQ (Frequently Asked Questions)

[🇺🇸 English FAQ](FAQ_EN.md) | [🇷🇺 ЧаВо на Русском](FAQ_RU.md) | [✓] 🇮🇹 FAQ in Italiano | [🇵🇱 FAQ po Polsku](FAQ_PL.md)

<details>
  <summary>Che versioni di iOS supporta YouTube Plus?</summary>
    <p>YouTube Plus supporta iOS 14 e superiori. <strong>Però</strong>, se stai eseguendo il sideload su un dispositivo senza jailbreak, devi tenere conto della compatibilità dell'app di YouTube con la tua versione di iOS. Sotto trovi una lista delle ultime versioni di YouTube supportate per ogni iOS:</p>
    <li><strong>iOS 14</strong>: YouTube v19.20.2</li>
    <li><strong>iOS 15</strong>: YouTube v20.21.6</li>
    <li><strong>iOS 16+</strong>: Qualsiasi versione</li>
</details>
<br>
<details>
  <summary>La mia versione di iOS non è più supportata dall'app YouTube. Cosa posso fare?</summary>
    <p>Ecco delle possibili opzioni:</p>
    <li><a href="https://ios.cfw.guide/get-started/">Esegui il jailbreak sul tuo dispositivo</a>, installa l'ultima versione di YouTube supportata nell'App Store, poi <a href="http://dvntm0.github.io/#jb">installa il tweak di YouTube Plus</a></li>
    <li><a href="https://ios.cfw.guide/installing-trollstore/">Installa TrollStore</a>, poi <a href="https://github.com/Lessica/TrollFools/releases/">TrollFools</a>, installa l'ultima versione di YouTube supportata nell'App Store, e installa <a href="https://github.com/dayanch96/YTLite/releases/">YouTube Plus</a> utilizzando TrollFools</li>
    <li>Trova un'IPA compatibile online e <a href="../README.md#how-to-build-a-youtube-plus-app-using-github-actions">builda YouTube Plus utilizzando Github actions</a></li>
</details>
<br>
<details>
  <summary>Il Cast non funziona più su YouTube Plus sideloaded. Cosa dovrei fare?</summary>
    <p>Finché non si risolve il problema, è consigliato usare YouTube 20.14.1 o inferiori.</p>
</details>
<br>
<details>
  <summary>Quando provo a riprodurre un video, mi esce <strong><em>Qualcosa è andato storto. Aggiorna e riprova più tardi.</em></strong></summary>
    <p>Prima di giungere a conclusioni affrettate, chiariamo un paio di cose:</p>
    <ol>
      <li><strong>Non è</strong> causato dall'ad blocking</li>
      <li><strong>Non è</strong> causato dal fatto che il tuo account è stato magicamente segnalato</li>
      <li><strong>Non è</strong> causato dal fatto che il tuo account è stato inserito in blacklist</li>
    </ol>
    <br>
    <p>Questo problema risiede nel processo del sideloading stesso, anche senza nessun tweak applicato. Potrebbe essere causato da VisitorID o VisitorData invalidi o mancanti, come suggerito <a href="https://github.com/pepeloni-away/userscripts/issues/6#issuecomment-2860641610">qui</a>. Questo errore è diventato più frequente a causa delle contromisure anti-download di YouTube.</p>
    <br>
    <p><strong>Possibili workaround temporanei:</strong></p>
    <ol>
      <li>Esci dal tuo account completamente: Vai su <em>Tab Tu → Cambia account → Gestisci account su questo dispositivo → Rimuovi da questo dispositivo</em></li>
      <li>Guarda un paio di video fino alla fine senza eseguire il login. Non eseguire il login per un paio d'ore.</li>
      <li>Riesegui il login nell'account con cui stavi avendo problemi</li>
    </ol>
</details>
