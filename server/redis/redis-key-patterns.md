# Redis / Memurai Key Pattern Document

Project: Online Proctoring and Cheating Detection System  
Tool: Memurai on Windows or Redis-compatible server

Redis is not the permanent database. PostgreSQL and MongoDB store permanent data. Redis is used for temporary, fast, real-time data.

## Naming rules

Use lowercase names and colon-separated parts:

```text
module:entity:id:subentity
```

Examples:

```text
auth:session:11111111-1111-1111-1111-111111111111:token-abc
exam:aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa:student:11111111-1111-1111-1111-111111111111:state
proctor:session:64f0abcd1234:latest-frame
```

## Key patterns

| Purpose | Key pattern | Value type | Example value | TTL |
|---|---|---|---|---|
| Logged-in user session | `auth:session:{userId}:{tokenId}` | String JSON | `{"role":"student","email":"aarav.student@example.com"}` | 2 hours |
| Login rate limit | `rate:login:{ipAddress}` | Integer | `3` | 15 minutes |
| Active WebSocket connection | `ws:user:{userId}` | String JSON | `{"socketId":"abc123","connectedAt":"2026-05-10T04:20:00Z"}` | While connected |
| Exam live state | `exam:{examId}:student:{studentId}:state` | String JSON | `{"status":"in_progress","currentQuestion":2}` | Exam duration + 30 min |
| Lock to avoid double submission | `lock:submit:{examId}:{studentId}` | String | `locked` | 60 seconds |
| Latest proctoring frame | `proctor:session:{videoSessionId}:latest-frame` | String JSON | `{"suspiciousScore":65,"flags":["LOOKING_AWAY"]}` | 10 minutes |
| Suspicious flag counter | `proctor:session:{videoSessionId}:flag-count` | Hash | `LOOKING_AWAY=4, PHONE_DETECTED=1` | Exam duration + 24 hours |
| Proctor dashboard room users | `proctor:exam:{examId}:connected-users` | Set | student IDs currently online | Exam duration + 30 min |
| WebSocket broadcast channel | `channel:exam:{examId}:alerts` | Pub/Sub | Alert event payload | No TTL |
| Temporary OTP/password reset | `auth:otp:{email}` | String | `845921` | 5 minutes |

## Example Redis commands

### 1. Store a login session

```bash
SETEX auth:session:11111111-1111-1111-1111-111111111111:token-abc 7200 '{"role":"student","email":"aarav.student@example.com"}'
```

### 2. Track login attempts

```bash
INCR rate:login:127.0.0.1
EXPIRE rate:login:127.0.0.1 900
```

### 3. Store active exam state

```bash
SETEX exam:aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa:student:11111111-1111-1111-1111-111111111111:state 5400 '{"status":"in_progress","currentQuestion":2,"startedAt":"2026-05-10T04:30:00Z"}'
```

### 4. Prevent duplicate exam submission

```bash
SET lock:submit:aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa:11111111-1111-1111-1111-111111111111 locked NX EX 60
```

### 5. Store latest suspicious frame summary

```bash
SETEX proctor:session:64f0abcd1234:latest-frame 600 '{"suspiciousScore":75,"flags":["PHONE_DETECTED"],"capturedAt":"2026-05-10T04:45:00Z"}'
```

### 6. Count suspicious flags

```bash
HINCRBY proctor:session:64f0abcd1234:flag-count PHONE_DETECTED 1
HINCRBY proctor:session:64f0abcd1234:flag-count LOOKING_AWAY 1
EXPIRE proctor:session:64f0abcd1234:flag-count 90000
```

### 7. Publish alert to proctor dashboard

```bash
PUBLISH channel:exam:aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa:alerts '{"studentId":"11111111-1111-1111-1111-111111111111","flag":"PHONE_DETECTED","severity":"high"}'
```

## What should not be stored permanently in Redis

Do not use Redis as the only place for:

- Final answers
- Final scores
- User accounts
- Disputes
- Permanent video session history
- Permanent frame analysis history

Those must be stored in PostgreSQL or MongoDB.

## Suggested TTL policy

| Data | Suggested TTL |
|---|---:|
| Login session | 2 hours |
| OTP | 5 minutes |
| Rate limit counter | 15 minutes |
| Exam live state | Exam duration + 30 minutes |
| Submit lock | 60 seconds |
| Latest frame summary | 10 minutes |
| Suspicious flag counter | 24 hours after exam |

## Why Redis/Memurai is useful here

The proctoring dashboard needs fast updates. Redis helps because it can store and publish temporary live information without repeatedly querying PostgreSQL or MongoDB for every small event.
