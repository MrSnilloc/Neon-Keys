# Neon Keys on your Samsung tablet

Your laptop keeps working exactly as before (Start Neon Keys.bat, the Songs folder,
Save\progress.json). This guide is only about the tablet.

Your tablet's address for Neon Keys is:

**https://mrsnilloc.github.io/Neon-Keys/**

---

## Part 1: Put the game online (one time, on the laptop, at github.com)

The tablet can only use your keyboard if the game comes from a proper web address,
so GitHub hosts it for free. Do this in Edge on the laptop, signed in to github.com:

1. **Accept the tablet update.** Open https://github.com/MrSnilloc/Neon-Keys, click the
   **Pull requests** tab, open the Neon Keys tablet one, and click **Merge pull request**, then **Confirm merge**.
2. **Turn on the website.** On the project page click **Settings** (top row, the gear),
   then **Pages** in the left menu.
   Under **Build and deployment**, set **Source** to **GitHub Actions**.
3. **Publish it.** Click the **Actions** tab at the top, click **Publish Neon Keys** on the
   left, then the **Run workflow** button, then the green **Run workflow**.
   After a minute or two a green tick appears. That's it, the address above now works.

The project is public, but your Songs folder and Save folder are never uploaded,
so your MIDI files and progress stay private.

From now on, every change to the game on GitHub is published automatically, and the
tablet picks it up by itself next time it's online.

---

## Part 2: The cable

Your Casio CTK-2090 has a square **USB-B** socket on the back. The tablet has **USB-C**. You need either:

- a **USB-C to USB-B cable** (sold as a "USB-C printer cable" or "USB-C MIDI cable"), or
- your existing keyboard cable plus a small **USB-C to USB-A adapter (OTG)**.

The keyboard still needs its own power (its mains adapter or batteries). The tablet can't power it.

---

## Part 3: Set up the tablet (one time)

1. Open **Chrome** on the tablet. (Use Chrome rather than Samsung Internet, which may not see the keyboard.)
2. Type the address **mrsnilloc.github.io/Neon-Keys** into the bar at the top and go.
3. Plug the keyboard into the tablet and switch the keyboard on.
   - If Android asks which app should open the USB device, just tap **Cancel**.
   - When Chrome asks to **connect to MIDI devices**, tap **Allow**.
   - The pill at the top of the menu should turn green: **Casio CTK-2090 connected**.
4. **Put the icon on your home screen:** tap Chrome's **⋮** menu (top right), then
   **Add to home screen** (it may say **Install app**), then **Install** / **Add**.

From now on just tap the **Neon Keys** icon. It opens full screen, sideways,
keeps the screen from going to sleep, and works even without Wi-Fi.

---

## Part 4: Getting your songs onto the tablet

The tablet has no Songs folder, so you add songs in the game instead:

1. Get the `.mid` files onto the tablet. The easiest way: on the laptop, drag your
   **Songs** folder into **Google Drive** (drive.google.com).
2. In Neon Keys, go to **FREE PLAY** and tap **+ ADD SONGS**.
3. The file picker opens. Tap the **☰** menu to choose **Drive** or **Downloads**, go to your songs,
   and **press and hold** one file, then tap the others to pick several at once. Tap **Select**.
4. Choose a group (like your laptop's subfolders: "Rock", "TV Themes"…) or type a new
   group name, and tap **ADD**. Each group becomes a tab in Free Play.

Each added song has an **EDIT** button to move it to another group or delete it.
Songs that are drums only can't be played and are skipped, just like on the laptop.

---

## Part 5: Your progress

- Progress (stars, scores, lessons, practice log, Studio songs) **saves automatically** on the tablet.
- **Keep a backup now and then:** **SETTINGS → BACK UP** saves a file into your **Downloads**.
  Upload it to Google Drive to keep it safe.
- **Bring your laptop progress to the tablet:** put the laptop's `Save\progress.json` into
  Google Drive, then on the tablet go to **SETTINGS → RESTORE…** and pick it.
- **Bring tablet progress back to the laptop:** on the tablet tap **BACK UP**, put that file
  in Google Drive, download it on the laptop, then in Neon Keys on the laptop go to
  **SETTINGS → RESTORE…** and pick it. It goes straight into `Save\progress.json`.
  (For this, your laptop needs the new `NeonKeys.html`, see Part 7.)

The laptop and the tablet don't sync by themselves. RESTORE replaces the progress on
that device with the backup, so restore the newest one.

⚠ Uninstalling the Neon Keys icon or clearing Chrome's data for the site erases the
tablet's progress and added songs. Make a backup first.

---

## Part 6: Playing with your fingers

- Tap a song, then the big **PLAY** button (or double-tap the song).
- During a song, tap **❙❙** at the top right to pause (the top C on your keyboard still works too).
- In Neon Studio: tap a square to add a note, drag to make it longer or move it,
  **double-tap** a note to delete it, and use **two fingers** to scroll.

---

## Part 7: Updating the laptop (optional)

The laptop keeps working with the files it has. To get the new **BACK UP / RESTORE**
buttons there too: on github.com open **NeonKeys.html**, click the **Download raw file** button
(the arrow pointing down), and put it into your Piano folder, replacing the old one.
Don't touch your Songs and Save folders.

---

## If something isn't working

| What you see | What to do |
|---|---|
| "Keyboard not found" | Check the keyboard is switched on and has power. Unplug the cable from the tablet and plug it back in. |
| "MIDI blocked" | In Chrome: **⋮ → Settings → Site settings**, open the **MIDI** setting, find mrsnilloc.github.io and set it to **Allow**. Then close and reopen Neon Keys. |
| No sound when you play | The keyboard makes the sound. Check its volume. |
| A song file won't add | It must be a `.mid`, `.midi` or `.kar` file with a tune in it (not drums only). |
