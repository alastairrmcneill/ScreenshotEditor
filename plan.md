## EPIC 1 – ✅ Done Project Setup & Architecture Foundations

### Story 1.1 – ✅ Done Implement MVVM Folder Structure

**Description:**

Define and create folders for `Models`, `Views`, `ViewModels`, and `Utilities`. Ensure future files are categorized correctly.

**Acceptance Criteria:**

- Folder structure includes `Models`, `Views`, `ViewModels`, `Utilities`.
- Example placeholder file in each directory to prevent removal by Git.

---

### Story 1.2 – ✅ Done UUID Generation and Keychain Persistence

**Description:**

Generate an anonymous UUID and persist it in the Keychain so it survives app reinstalls.

**Acceptance Criteria:**

- On first launch, a UUID is created and stored in Keychain.
- On subsequent launches, the same UUID is retrieved.
- Include helper class for Keychain operations.

---

### Story 1.3 – ✅ Done Integrate Mixpanel Analytics SDK

**Description:**

Install Mixpanel SDK and set up basic configuration with an environment flag (`prod` or `debug`).

**Acceptance Criteria:**

- Mixpanel initialized with project token.
- Environment flag (`prod` or `debug`) included in all events.
- App builds and runs without analytics crashing.

---

### Story 1.4 – ✅ Done UserDefaults Wrappers for State Flags

**Description:**

Create UserDefaults utility to track onboarding completion and free export count.

**Acceptance Criteria:**

- Wrapper class exists for reading/writing onboarding flag.
- Export count increments and persists correctly

---

## EPIC 2 – ✅ Done Image Import & Editor Canvas

### Story 2.1 – ✅ Done Empty State UI with Import Button

**Description:**

Design an empty state with a centered button to import photos.

**Acceptance Criteria:**

- Empty state displays when no image is loaded.
- Button is labeled “Import Photo” and centered on screen.

---

### Story 2.2 – ✅ Done Configure PHPicker with Screenshot Filter

**Description:**

Use PHPicker to allow users to pick screenshots. Fallback to all photos if unavailable.

**Acceptance Criteria:**

- PHPicker is presented on button tap.
- Defaults to `.screenshots` filter.
- Image is returned and displayed.

---

### Story 2.3 – ✅ Done Load Selected Image into Editor

**Description:**

Display the selected image in the main canvas.

**Acceptance Criteria:**

- Selected image is shown centered on screen.
- Live editing view renders below navigation bar.

---

### Story 2.4 – ✅ Done Add Watermark for Free Users

**Description:**

Render "Made with SnapPolish" watermark in bottom-right corner for free users.

**Acceptance Criteria:**

- Watermark appears in editor preview and exports.
- Subscribed users do not see watermark.

---

### Story 2.5 – ✅ Done Core Image Pipeline for Rendering

**Description:**

Set up a basic image processing pipeline using Core Image. Render the imported image with current crop and style values.

**Acceptance Criteria:**

- Image is rendered using Core Image.
- Changes to parameters (e.g. corner radius) reflect live.
- Placeholder architecture for Metal if needed.

---

## EPIC 3 – ✅ Done Crop Functionality

### Story 3.1 – ✅ Done Build Crop Screen UI

**Description:**
Create a modal crop view that shows the original bitmap with a rule-of-thirds overlay grid and draggable crop handles.

**Acceptance Criteria:**

- Crop screen displays image with handles at corners and midpoints.
- Grid overlays on top of the image.
- Crop UI responds to drag gestures and resizes crop frame accordingly.

---

### Story 3.2 – ✅ Done Store Crop as CGRect Mask

**Description:**
When cropping, save the user-selected area as a CGRect rather than modifying the image data.

**Acceptance Criteria:**

- Crop selection persists as a CGRect in memory.
- The user can reopen crop and adjust it further.

---

### Story 3.3 – ✅ Done Apply Non-Destructive Crop in Editor Preview

**Description:**
Use Core Image to apply the crop mask in real-time preview without changing the original image.

**Acceptance Criteria:**

- Editor preview reflects crop mask.
- Image rendering respects non-destructive crop.

---

## EPIC 4 – ✅ Done Style Editing Panel

### Story 4.1 – ✅ Done Create Bottom Sheet UI for Style Panel

**Description:**
Add a bottom sheet view with controls for corner radius, padding, and shadow options.

**Acceptance Criteria:**

- Panel slides up/down and dismisses on outside tap.
- All controls spaced evenly with 16pt padding around content.

---

### Story 4.2 – ✅ Done Corner Radius Slider Implementation

**Description:**
Add a slider for corner radius from 0–48pt with live updates.

**Acceptance Criteria:**

- Slider reflects current radius.
- Changing value updates image in canvas.

---

### Story 4.3 – ✅ Done Padding Slider Implementation

**Description:**
Add a slider to adjust padding from 0–48pt.

**Acceptance Criteria:**

- Padding value reflects on canvas in real time.
- Min value is 0, default is 24.

---

### Story 4.4 – ✅ Done Shadow Toggle and Sliders

**Description:**
Implment shadow slider for enabling and determining the size of the drop shadow. One slider will be used to control the drop shadow properties such as offset, blur and opacity.

**Acceptance Criteria:**

- Slider reflect and control offset (0pt default), blur (20pt), opacity (30%).
- Properties get applied live to the selected image on the canvas, but inside the outer background.

---

## EPIC 5 – ✅ Done Background & Sizing Options

### Story 5.1 – ✅ Done Background Panel with Segmented Control

**Description:**
Create a bottom sheet with segmented control for Solid and Gradient backgrounds.

**Acceptance Criteria:**

- Switching segment updates the grid.
- Default segment = Gradient.

---

### Story 5.2 – ✅ Done Display Grid of Predefined Solid Colours

**Description:**
Display circle buttons with 10 solid colour swatches. Update background on tap.

**Acceptance Criteria:**

- Tapping a colour updates background instantly.
- Selection is visually highlighted.

---

### Story 5.3 – ✅ Done Display Grid of Gradient Presets

**Description:**
When Gradient segment is selected, show 10 gradient swatches.

**Acceptance Criteria:**

- Gradients applied on tap.
- Each button preview represents real gradient direction and colours.

---

### Story 5.4 – ✅ Done Implement Aspect Ratio Control Panel

**Description:**
Provide 4 options: 1:1, 9:16, 16:9, Free. Applies only to background area.

**Acceptance Criteria:**

- Resizing affects background only.
- Foreground image remains unchanged.
- Active ratio is visually highlighted.

---

## EPIC 6 – Exporting & Share Sheet

### Story 6.1 – ✅ Done Add Share Button and UIActivityViewController

**Description:**
Use the system share sheet to allow image exporting.

**Acceptance Criteria:**

- Share button opens share sheet.
- Image preview is shared in current state (crop + style + background).
- Option to just save photo or to share to other apps

---

### Story 6.2 – ✅ Done Export Final Image as PNG

**Description:**
Combine cropped image, padding, background and style settings into a final image.

**Acceptance Criteria:**

- Exported PNG reflects what’s shown on canvas.
- Watermark included for free users.

---

### Story 6.3 – Enforce Free Export Limit

**Description:**
Track how many exports a free user has done. Show paywall if limit exceeded.

**Acceptance Criteria:**

- Free users allowed 3 exports max.
- Paywall shown on 4th attempt.

---

### Story 6.4 – Trigger In-App Review Prompt

**Description:**
Prompt user for a review after their first successful export.

**Acceptance Criteria:**

- Prompt shown once.
- Not repeated after first display.

---

## EPIC 7 – Onboarding & Paywall Flow

### Story 7.1 – Build 4-Slide Onboarding Sequence

**Description:**
Present 4 full-screen slides explaining app, demoing features, requesting access, and presenting the paywall.

**Acceptance Criteria:**

- Slides swipe horizontally.
- No skip allowed.
- Slide 4 = paywall.

---

### Story 7.2 – Implement Photo Access Request

**Description:**
On slide 3, request photo library access using Apple’s privacy prompt.

**Acceptance Criteria:**

- Request triggered when reaching Slide 3.
- User must respond to proceed.

---

### Story 7.3 – Present Paywall Screen

**Description:**
Show paywall with annual preselected and weekly alternative. Terms, Privacy, Restore in footer.

**Acceptance Criteria:**

- Tapping “Continue” triggers StoreKit purchase.
- Restore button functional.

---

### Story 7.4 – Track Paywall Impressions and Conversions

**Description:**
Log paywall views and purchases in Mixpanel.

**Acceptance Criteria:**

- Paywall impressions tracked.
- Successful subscription triggers conversion event.

---

## EPIC 8 – Limits & Freemium Logic

### Story 8.1 – Implement Export Count Tracking

**Description:**
Use UserDefaults to track the number of exports done by free users.

**Acceptance Criteria:**

- Value persists across sessions.
- Accurate count shown internally.

---

### Story 8.2 – Add Watermark for Free Users Only

**Description:**
Watermark is visible in canvas and final export for free users.

**Acceptance Criteria:**

- Subscribed users don’t see watermark.
- Watermark auto-removed post-purchase.

---

### Story 8.3 – Disable Save Presets for Free Users

**Description:**
In free version, UI to save style presets is disabled or hidden.

**Acceptance Criteria:**

- Long-press Save Preset disabled or greyed out.
- Tooltip or alert prompts upgrade.

---

## EPIC 9 – Analytics & Event Tracking

### Story 9.1 – Track Onboarding Step Views

**Description:**
Log each onboarding slide view in Mixpanel with slide number.

**Acceptance Criteria:**

- Slide 1 through 4 logged.
- Includes UUID and environment.

---

### Story 9.2 – Track Export Parameters

**Description:**
When user exports, log snapshot of corner radius, padding, shadow, background type.

**Acceptance Criteria:**

- All parameter values sent.
- Sent immediately after export.

---

### Story 9.3 – Track Share Sheet Opens

**Description:**
Log when share sheet is presented.

**Acceptance Criteria:**

- Event logged when share sheet opens.
- Includes current editing state.

---

## EPIC 10 – Final Polish, QA & Compliance

### Story 10.1 – Replace Onboarding Placeholder Text

**Description:**
Use real reviews and social proof quotes in onboarding Slide 1.

**Acceptance Criteria:**

- Text content reviewed and approved.
- Star rating UI visible.

---

### Story 10.2 – Shadow Value Tuning

**Description:**
Adjust default shadow blur/opacity based on beta testing feedback.

**Acceptance Criteria:**

- Final values set and documented.
- QA validated on all test devices.

---

### Story 10.3 – QA Device Matrix Testing

**Description:**
Run final QA on iPhone SE-3 and iPhone 15 Pro Max.

**Acceptance Criteria:**

- All flows function correctly.
- UI scales appropriately.

---

### Story 10.4 – Ensure GDPR/CCPA Compliance

**Description:**
Validate analytics are anonymous and compliant.

**Acceptance Criteria:**

- No user PII collected.
- UUID is anonymous and opt-out not required.

---

## EPIC 11 – Post-Launch Enhancements

### Story 11.1 – Add iPad & Landscape Layout Support

**Description:**
Support layout variations for iPad and horizontal orientation.

**Acceptance Criteria:**

- Editor screen adapts to larger layout.
- Landscape orientation behaves correctly.

---

### Story 11.2 – Implement Saved Style Presets (Premium)

**Description:**
Allow SnapPolish+ users to save and apply custom style presets.

**Acceptance Criteria:**

- Long-press saves style config.
- Presets UI shows list for reuse.

---

### Story 11.3 – Build Multi-Screenshot Collage Tool

**Description:**
Add functionality to combine multiple screenshots in a layout.

**Acceptance Criteria:**

- User can import 2–4 images.
- Choose layout (grid, vertical, side-by-side).

---

### Story 11.4 – Shortcuts & Siri Intent Integration

**Description:**
Enable automation for styling and exporting via Shortcuts app.

**Acceptance Criteria:**

- Expose Siri intents.
- App supports Shortcut actions.

---

### Story 11.5 – Push Notification Engagement Flow

**Description:**
Create a notification flow for engagement and reactivation.

**Acceptance Criteria:**

- User prompted for permission.
- Notifications triggered by inactivity or new features.
