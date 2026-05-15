# MeetRadius — MVP gaps & areas needing more work

This document tracks what **[PRODUCT_MVP.md](PRODUCT_MVP.md)** still expects for v1 versus what the app implements today. Use it for planning; it complements [PRODUCT_FLOWS.md](PRODUCT_FLOWS.md) (connectivity) and the shipped chat/safety work in `lib/features/chat/` and `lib/features/safety/`.

**Last reviewed:** 2026-05-15

---

## At a glance

| Area | MVP priority | Status | Needs work |
|------|----------------|--------|------------|
| Home feed (live + upcoming, 15 mi) | P0 | Done | Polish sort/copy; live window rules TBD |
| Host / join / leave activity | P0 | Done | — |
| Group chat (per activity) | P0 | Done | Message pagination optional |
| GPS check-in | P0 | Done | Streak not tied to check-ins yet |
| Report / block / mute | P0 | Mostly done | Standalone “report user”; admin review UI |
| In-app notifications + deep links | P0 | Done | — |
| Push (FCM) | P1 | Code present | Deploy functions + console setup |
| Basic profile + stats | P0 | Partial | Streak, profile photo |
| Friends attending on cards | P1 | Not built | Friend model or remove UI |
| Manual city + ZIP anchor | P1 | Partial | Lat/lng only; no city/ZIP picker |
| Weekly activity streak | P0 | Not built | Data model + profile UI |
| Server scheduled activity end | P1 | Not built | Cloud Function on `endsAt` |
| Firestore rules (messages) | P0 | In repo | Must deploy to Firebase |
| Badge visuals | V2 | Deferred | Plain stats OK for MVP |
| Travel mode | V2 | Deferred | — |
| AI moderation | V2 | Deferred | Manual reports only |
| Admin dashboard | Later | Deferred | Reports go to `reports` collection |

---

## Core loop — what’s solid

These support the MVP narrative: **open app → feed → join → chat → show up → check in → profile**.

- Auth, main shell (Feed, Map, Chats, Menu)
- Host activity (time, place, capacity, live/upcoming, scheduled end)
- Feed and map discovery with **15-mile** radius and discovery anchor ([discovery_config.dart](../lib/core/discovery/discovery_config.dart))
- Join / leave, activity detail, host manage (end / edit / delete)
- **Group chat**: send/reply, system lines (joined, left, ended, checked in), ended-thread UX, chats hub, unread badges
- **Check-in**: geofence (~150 m), detail + chat entry points, host in-app notification
- **Safety**: report activity / message / host, block host, mute thread, `notifyChat` on user doc
- **Notifications**: Firestore inbox, bell unread count, tap → activity or chat
- Profile: hosted / joined / check-in **counts**, joined tab

---

## Missing or incomplete (MVP spec)

### 1. Weekly activity streak (P0)

**Spec ([PRODUCT_MVP.md](PRODUCT_MVP.md)):** Streak progress when users **check in** to joined activities within a weekly boundary; show on profile (optionally in member lists).

**Today:** Profile shows Hosted / Joined / Check-ins counts only. No streak field, no week rollover logic, no profile streak UI.

**Suggested work:**

- Define week boundary (e.g. ISO week, local midnight Sunday).
- Store on `users/{uid}`: e.g. `streakCount`, `streakWeekKey`, `lastCheckInWeekKey`.
- Increment on successful `checkInToActivity` when check-in falls in current week.
- Profile header: “X-week streak” (or “Start your streak” when 0).

**Touchpoints:** [check_in_activity.dart](../lib/features/activity/data/check_in_activity.dart), [profile_screen.dart](../lib/features/profile/presentation/profile_screen.dart).

---

### 2. Friends attending (P1)

**Spec:** Activity cards show real names when friends are going (“Alex, Jordan”).

**Today:** [live_activity_card.dart](../lib/features/feed/presentation/widgets/live_activity_card.dart) supports `friendNamesLine`, but [feed_body.dart](../lib/features/feed/presentation/widgets/feed_body.dart) always passes `null`. No friend list, invites-as-friends, or mutual-join model.

**Options (pick one for MVP):**

- **A — Wire minimal friends:** e.g. `users/{uid}/friendIds` from invite acceptance or manual add; compute overlap with `activity.memberIds` for card subtitle.
- **B — Honest MVP:** Remove friend row from cards until V2 (PRODUCT_FLOWS Option B).

**Open product question:** Friend graph source (contacts, invite link, mutuals) — see MVP appendix.

---

### 3. Profile photo (P0 in “minimal profile”)

**Spec:** One profile photo + first name (display name).

**Today:** [user_profile.dart](../lib/features/profile/domain/user_profile.dart) has names and email; avatar is **initials** only. Gallery tab exists but is separate from a single MVP profile photo.

**Suggested work:**

- `photoUrl` on `users/{uid}` (Firebase Storage upload flow).
- Show photo on profile, and optionally in chat sender line / member list later.

---

### 4. Manual city + ZIP discovery (P1)

**Spec:** Discovery anchor = **GPS** or **manual city + ZIP** (not only saved coordinates).

**Today:** GPS toggle + saved lat/lng in SharedPreferences ([settings_repository.dart](../lib/features/settings/data/settings_repository.dart)); header copy uses a default label (e.g. “Davao City · 15 mi”). No structured city/ZIP entry or geocoding.

**Suggested work:**

- Settings: city + ZIP fields → geocode once → save anchor lat/lng + display label on user doc or prefs.
- Clear copy when GPS is off vs on.

---

### 5. “Report user” everywhere MVP implies (P1)

**Today:**

- Report **activity**, **message**, **host** — implemented ([submit_report.dart](../lib/features/safety/data/submit_report.dart), group info, long-press on bubbles).
- **Block** host — implemented.

**Gap:** No **Report user** from a generic member profile or activity members list (only “report host” in group info).

**Suggested work:** Report action on [activity_members_screen.dart](../lib/features/activity/presentation/activity_members_screen.dart) or public profile with `reportedUserUid` + optional `activityId`.

---

### 6. Human moderation workflow (ops, not app UI)

**Spec:** MVP relies on **manual review** of reports (no AI).

**Today:** Reports write to Firestore `reports` with `status: pending`. No in-app admin console, no email/Slack hook, no reviewer tooling.

**Suggested work (outside Flutter or internal tool):**

- Firebase console / Retool / simple admin web app to list and resolve reports.
- Document SLA and escalation in ops runbook (not required for store build).

---

## Backend & production — needs deploy / more work

### Firestore security rules

Member-only **read/create** on `activities/{id}/messages` is defined in [firestore.rules](../firebase/firestore.rules). Rules must be **deployed** or production remains permissive on older deployed rules.

```bash
firebase deploy --only firestore:rules
```

### Push notifications (FCM)

**Client:** [push_notification_service.dart](../lib/features/notifications/data/push_notification_service.dart) registers tokens on `users/{uid}.fcmTokens`.

**Server:** [firebase/functions/index.js](../firebase/functions/index.js) sends FCM when an in-app notification is created (respects `notifyChat` and `mutedActivityIds` for chat).

**Still needed:**

- Deploy Cloud Functions (`npm install` in `firebase/functions`, then `firebase deploy --only functions`).
- Enable Cloud Messaging in Firebase Console; Android `POST_NOTIFICATIONS`; iOS capabilities if shipping iOS.
- Verify end-to-end on a physical device.

### Scheduled activity end (server)

**Today:** [sync_due_hosted_activities.dart](../lib/features/activity/data/sync_due_hosted_activities.dart) runs when the **host** opens the app or resumes — not at exact `endsAt` time.

**Gap:** No Cloud Function to call the same end logic as [apply_activity_end.dart](../lib/features/activity/data/apply_activity_end.dart) when `endsAt <= now`.

**Suggested work:** Scheduled function (every 1–5 min) query activities where `endsAt` passed and `endedAt == null`, apply end + member notifications.

---

## Polish & scale (not blocking MVP launch)

| Item | Notes |
|------|--------|
| Chat message pagination | [watch_activity_messages.dart](../lib/features/chat/data/watch_activity_messages.dart) loads last 200 only; add “load earlier” if threads grow. |
| FCM open-from-background routing | Token sync exists; deep link from notification tap to chat may need `onMessageOpenedApp` wiring in [app.dart](../lib/app.dart). |
| Live activity window | Spec TBD: 60 minutes vs host `isLive` only — align product rule and feed filters. |
| Host check-in list UI | Host gets notification; dedicated “who checked in” panel on detail could be clearer. |
| Streak on participant lists | Optional per MVP; profile is minimum. |

---

## Intentionally out of MVP scope (do not treat as bugs)

From **Hold for V2 / later** in [PRODUCT_MVP.md](PRODUCT_MVP.md):

- **Badge visuals** (milestone chips, category badges) — plain stats are enough for v1.
- **Travel mode** — browse another city while not there.
- **AI moderation** — assist-only in V2.
- **DMs** outside joined activity threads.
- **Rich profiles** (multi-photo grids, bios-as-feeds).
- **Full admin dashboards** — start with Firestore + manual review.

**Doc vs app note:** PRODUCT_MVP lists **in-app map discovery** as V2, but the app already ships a **Map** tab. That is ahead of the written spec, not a missing MVP item.

---

## Documentation drift

[PRODUCT_FLOWS.md](PRODUCT_FLOWS.md) § “What exists today” is **out of date** (e.g. still says check-in and push not built, notifications placeholder). Prefer this file and the codebase when planning. Consider updating PRODUCT_FLOWS in a separate pass.

---

## Suggested implementation order

1. **Deploy** Firestore rules + notification Cloud Function; verify FCM on device.
2. **Weekly streak** + tie to check-in (unblocks “profile promise”).
3. **Friends attending** — implement minimal model **or** remove card placeholder.
4. **Profile photo** upload + display.
5. **City + ZIP** anchor UI.
6. **Report user** from members/profile.
7. **Cloud Function** scheduled activity end.

---

## Related files

| Topic | Location |
|-------|----------|
| MVP product spec | [PRODUCT_MVP.md](PRODUCT_MVP.md) |
| Screen connectivity | [PRODUCT_FLOWS.md](PRODUCT_FLOWS.md) |
| Chat implementation gaps (completed plan) | `lib/features/chat/`, `lib/features/safety/` |
| Discovery | `lib/core/discovery/` |
| Check-in | `lib/features/activity/data/check_in_activity.dart` |
| Firebase | `firebase/firestore.rules`, `firebase/functions/` |
