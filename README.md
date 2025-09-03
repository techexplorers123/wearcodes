# WearCodes

![WearCodes Icon](assets/icon.png)

A simple and efficient Flutter application for Wear OS that allows you to store and display barcodes directly on your smartwatch. Never forget your loyalty cards, gym membership, or library card again!

## 🌟 Features

- **Store Multiple Codes:** Add and manage a list of barcodes with custom names.
- **Clear Barcode Display:** Generates and displays crisp Code 39 barcodes optimized for smartwatch screens.
- **Intuitive Navigation:** Seamlessly cycle through your saved codes using the watch's rotary input (bezel or crown).
- **On-Device Management:** Add new codes or delete existing ones directly from the watch.
- **Haptic Feedback:** Physical confirmation for interactions like scrolling and adding codes.
- **Persistent Storage:** Your codes are saved locally on your device for quick access.

## 📲 How It Looks

*(Imagine a GIF here showing a user scrolling through different barcode cards on a smartwatch, then tapping to add a new one.)*

## 🛠️ Tech Stack & Dependencies

- **Framework:** [Flutter](https://flutter.dev/)
- **Platform:** Wear OS
- **Key Packages:**
  - `wear_plus`: For adapting the UI to different watch shapes (round/square).
  - `wearable_rotary`: To enable navigation with the physical rotating bezel or crown.
  - `barcode_widget`: For generating the barcode images.
  - `shared_preferences`: For storing the barcode data locally on the device.

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

- Flutter SDK installed. See [Flutter documentation](https://flutter.dev/docs/get-started/install) for instructions.
- A Wear OS emulator set up in Android Studio or a physical Wear OS device.

### Installation

1. **Clone the repo:**
   ```sh
   git clone https://github.com/your_username/wearcodes.git
   ```
2. **Navigate to the project directory:**
   ```sh
   cd wearcodes
   ```
3. **Install dependencies:**
   ```sh
   flutter pub get
   ```
4. **Run the app:**
   Connect your Wear OS device or start an emulator, then run:
   ```sh
   flutter run
   ```

## Usage

- **Scroll Through Codes:** Use the rotary input (bezel/crown) on your watch to switch between saved barcodes.
- **Add a New Code:** Scroll to the very end of your list to find the "Add New Code" card and tap the `+` button.
- **Delete a Code:** Long-press on any barcode card to bring up the delete confirmation screen.

## 📄 License

Distributed under the GPLv3 License. See `LICENSE` for more information.