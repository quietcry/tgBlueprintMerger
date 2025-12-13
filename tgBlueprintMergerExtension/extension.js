const vscode = require('vscode');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {
    console.log('tgMerge Extension is now active!');
    
    // Make script executable if it exists in extension directory
    const extensionScriptPath = path.join(context.extensionPath, 'tgBlueprintMerger_yaml_jinja.sh');
    if (fs.existsSync(extensionScriptPath)) {
        // Make script executable (works on Unix-like systems)
        if (process.platform !== 'win32') {
            fs.chmodSync(extensionScriptPath, 0o755);
        }
        console.log('Extension script made executable:', extensionScriptPath);
    }

    // Register the Save & Merge command
    let disposable = vscode.commands.registerCommand('tgMerge.saveAndMerge', async function () {
        const editor = vscode.window.activeTextEditor;
        
        if (!editor) {
            vscode.window.showWarningMessage('No active editor');
            return;
        }

        const document = editor.document;
        const filePath = document.fileName;
        const fileDir = path.dirname(filePath);
        const fileName = path.basename(filePath);

        // Save the file first
        await document.save();

        // Find the base file (*_*.yaml) in the same directory
        // Base file is always determined by directory name (independent of .package file)
        const dirName = path.basename(fileDir);
        const baseFileName = `${dirName}_.yaml`;
        const baseFilePath = path.join(fileDir, baseFileName);

        // Check if base file exists
        if (!fs.existsSync(baseFilePath)) {
            vscode.window.showErrorMessage(
                `Base file not found: ${baseFileName}. Please ensure the base file exists in the same directory.`
            );
            return;
        }

        // Use the base file path for merging
        const mergeFilePath = baseFilePath;

        // Get the merge script path
        const scriptName = 'tgBlueprintMerger_yaml_jinja.sh';
        let scriptPath = null;
        
        // First, check if a custom path is configured
        const config = vscode.workspace.getConfiguration('tgBlueprintMerger', document.uri);
        const configuredPath = config.get('scriptPath', '');
        
        if (configuredPath) {
            // Use configured path (can be absolute or relative to workspace root)
            const workspaceFolder = vscode.workspace.getWorkspaceFolder(document.uri);
            if (workspaceFolder && !path.isAbsolute(configuredPath)) {
                // Relative path: resolve from workspace root
                scriptPath = path.join(workspaceFolder.uri.fsPath, configuredPath);
            } else {
                // Absolute path or no workspace
                scriptPath = configuredPath;
            }
            
            // Verify the configured path exists
            if (!fs.existsSync(scriptPath)) {
                vscode.window.showErrorMessage(
                    `Configured script path not found: ${scriptPath}. Please check your settings.`
                );
                return;
            }
            } else {
                // No custom path configured, try automatic discovery
                // First, try to use script from extension directory
                const extensionScriptPath = path.join(context.extensionPath, scriptName);
                if (fs.existsSync(extensionScriptPath)) {
                    scriptPath = extensionScriptPath;
                    console.log('Using script from extension directory:', scriptPath);
                } else {
                // If not in extension, try to find script in workspace root
                const workspaceFolder = vscode.workspace.getWorkspaceFolder(document.uri);
                if (workspaceFolder) {
                    const workspaceScriptPath = path.join(workspaceFolder.uri.fsPath, scriptName);
                    if (fs.existsSync(workspaceScriptPath)) {
                        scriptPath = workspaceScriptPath;
                    }
                }
                
                // If not found, try relative to the file (go up directories to find it)
                if (!scriptPath) {
                    let currentDir = fileDir;
                    for (let i = 0; i < 10; i++) { // Max 10 levels up
                        const testPath = path.join(currentDir, scriptName);
                        if (fs.existsSync(testPath)) {
                            scriptPath = testPath;
                            break;
                        }
                        const parentDir = path.dirname(currentDir);
                        if (parentDir === currentDir) break; // Reached root
                        currentDir = parentDir;
                    }
                }
            }
            
            if (!scriptPath) {
                vscode.window.showErrorMessage(
                    `Script ${scriptName} not found. Please ensure it is in the extension directory, workspace root, configure the path in settings (tgBlueprintMerger.scriptPath), or place it in the same directory as your Blueprint files.`
                );
                return;
            }
        }
        
        // Show progress
        vscode.window.withProgress({
            location: vscode.ProgressLocation.Notification,
            title: "Merging Blueprint",
            cancellable: false
        }, async (progress) => {
            return new Promise((resolve, reject) => {
                const baseFileName = path.basename(mergeFilePath);
                progress.report({ increment: 0, message: `Processing ${baseFileName}...` });

                // Execute the merge script with the base file
                exec(`bash "${scriptPath}" "${mergeFilePath}"`, (error, stdout, stderr) => {
                    if (error) {
                        vscode.window.showErrorMessage(`Merge failed: ${error.message}`);
                        console.error(`Error: ${error.message}`);
                        console.error(`Stderr: ${stderr}`);
                        reject(error);
                        return;
                    }

                    progress.report({ increment: 100, message: "Merge completed!" });
                    
                    // Show success message
                    const outputChannel = vscode.window.createOutputChannel('tgMerge');
                    outputChannel.appendLine(stdout);
                    outputChannel.show(true);
                    
                    const baseFileName = path.basename(mergeFilePath);
                    vscode.window.showInformationMessage(`Home Assistant Blueprint merged successfully: ${baseFileName}`);
                    resolve();
                });
            });
        });
    });

    context.subscriptions.push(disposable);

    // Optional: Add status bar item
    const statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
    statusBarItem.command = 'tgMerge.saveAndMerge';
    statusBarItem.text = "$(merge) Merge";
    statusBarItem.tooltip = "Save & Merge Home Assistant Blueprint";
    
    // Show status bar item when any file in a blueprint directory is open
    const updateStatusBar = () => {
        const editor = vscode.window.activeTextEditor;
        if (editor) {
            const fileDir = path.dirname(editor.document.fileName);
            const dirName = path.basename(fileDir);
            const baseFileName = `${dirName}_.yaml`;
            const baseFilePath = path.join(fileDir, baseFileName);
            // Show if base file exists in the directory
            if (fs.existsSync(baseFilePath)) {
                statusBarItem.show();
            } else {
                statusBarItem.hide();
            }
        } else {
            statusBarItem.hide();
        }
    };

    updateStatusBar();
    vscode.window.onDidChangeActiveTextEditor(updateStatusBar);
    context.subscriptions.push(statusBarItem);
}

function deactivate() {}

module.exports = {
    activate,
    deactivate
}











