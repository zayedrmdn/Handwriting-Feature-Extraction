# 📝 Handwriting Feature Extraction GUI

A **MATLAB-based GUI** for handwriting analysis, allowing users to **upload handwriting images, apply multiple feature extraction scripts, and classify handwriting styles** (print, cursive, etc.).

## 📌 Features

✅ **Baseline Consistency Analysis**  
✅ **Slant Angle Detection**  
✅ **Letter Spacing Measurement**  
✅ **Stroke Continuity Evaluation**  
✅ **Expandable with Custom Scripts**  

---

## 📥 Cloning the Repository

### Using GitHub Desktop:
1. Open **GitHub Desktop**.
2. Go to **File** → **Clone Repository**.
3. Select **"URL"** and enter:
https://github.com/YourUsername/Handwriting-Feature-Extraction.git
4. Choose a folder to store the project.
5. Click **"Clone"** and wait for the process to finish.

### Using Git Bash or Terminal:
```
git clone https://github.com/YourUsername/Handwriting-Feature-Extraction.git
```
## 📂 Project Structure
```
📁 Handwriting-Feature-Extraction
│── 📂 src/                  # MATLAB feature extraction scripts
│── 📂 test_images/          # Sample handwriting images
│── 📂 gui/                  # GUI source files
│── 📄 main_gui.mlapp        # MATLAB App Designer GUI
│── 📄 README.md             # Documentation
│── 📄 log.txt               # Log file for analysis results
```
## 🚀 Running the GUI
### 📌 Prerequisites
1. Ensure MATLAB is installed.
2. Install the Image Processing Toolbox.

### 📌 Steps to Run
1. Open MATLAB.
2. Navigate to the cloned folder:
```
cd 'C:\path\to\Handwriting-Feature-Extraction'
```
3. Run the GUI:
```
main_gui
```
4. Usage:
    - Upload a handwriting image.
    - Select a handwriting style.
    - Pick up to 3 features.
    - Click "Run Analysis".

### 🛠️ Adding Custom Feature Extraction Scripts
#### 1️⃣ Create a New Script
- Place it inside the /src/ folder.
- Ensure the function name matches the script filename.

📌 Example (slant_detection.m):
```
function result = slant_detection(imagePath)
    % Load image
    img = imread(imagePath);
    
    % Perform some analysis (Example: Count black pixels)
    blackPixels = sum(img(:) == 0);
    
    % Return structured results
    result = struct('BlackPixelCount', blackPixels, 'Type', 'Custom Analysis');
end
```
#### 2️⃣ Register the New Script in the GUI
Modify `RunAnalysisButtonPushed.m` inside `main_gui.mlapp`.
📌 Step 1: Update the script list
Find this section:
```
scriptMap = containers.Map( ...
    {'Baseline Detection', 'Slant Detection', 'Letter Spacing', 'Stroke Continuity'}, ...
    {@baseline_detection, @slant_detection, @space_detection, @stroke_detection} ...
);
```
Add your function:
```
scriptMap('Custom Feature') = @custom_feature;
```
📌 Step 2: Update Dropdown List
Inside createComponents(), update the dropdown menu:
```
app.SelectFeature1DropDown.Items = {'Baseline Detection', 'Slant Detection', 'Letter Spacing', 'Stroke Continuity', 'Custom Feature'};
```

### 🔄 Updating & Contributing
#### 📌 Create Your Own Branch
- Open GitHub Desktop.
- Click Branch → New Branch.
- Name your branch (e.g., feature-name) and click Create Branch.

#### 📌 Contributing
- Make changes in MATLAB.
- Open GitHub Desktop.
- Under Changes, enter a commit message.
- Click Commit to [your-branch-name].
- Click Push origin to upload your changes.
- Open GitHub and create a Pull Request.
