#ifndef SETTINGS_H_
#define SETTINGS_H_

#define UserIDKey @"RYD-USER-ID"
#define RegistrationConfirmedKey @"RYD-USER-REGISTERED"
#define DidShowEnableVoteSubmissionAlertKey @"RYD-DID-SHOW-VOTE-SUBMISSION-ALERT"
#define DidResetUserIDKey @"RYD-DID-RESET-USER-ID"

#define _LOC(b, x) [b localizedStringForKey:x value:nil table:nil]
#define LOC(x) _LOC(tweakBundle, x)

#endif
