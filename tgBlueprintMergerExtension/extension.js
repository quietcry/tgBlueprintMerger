const vscode = require('vscode');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

// Internationalization helper
const l10n = vscode.l10n;

/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {
    console.log('tgMerge Extension is now active!');
    
    // Script is not included in extension - it must be in the workspace

    // Register the Save & Merge command
    let disposable = vscode.commands.registerCommand('tgMerge.saveAndMerge', async function () {
        const editor = vscode.window.activeTextEditor;
        
        if (!editor) {
            vscode.window.showWarningMessage(l10n.t('No active editor'));
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
                l10n.t('Base file not found: {0}. Please ensure the base file exists in the same directory.', baseFileName)
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
                    l10n.t('Configured script path not found: {0}. Please check your settings.', scriptPath)
                );
                return;
            }
            } else {
                // No custom path configured, try automatic discovery
                // Script must be in workspace (not in extension)
                // First, try to find script in workspace root
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
                l10n.t('Script {0} not found. Please ensure it is in the workspace root, configure the path in settings (tgBlueprintMerger.scriptPath), or place it in the same directory as your Blueprint files.', scriptName)
            );
            return;
        }
        
        // Show progress
        vscode.window.withProgress({
            location: vscode.ProgressLocation.Notification,
            title: l10n.t('Merging Blueprint'),
            cancellable: false
        }, async (progress) => {
            return new Promise((resolve, reject) => {
                const baseFileName = path.basename(mergeFilePath);
                progress.report({ increment: 0, message: l10n.t('Processing {0}...', baseFileName) });

                // Execute the merge script with the base file
                exec(`bash "${scriptPath}" "${mergeFilePath}"`, (error, stdout, stderr) => {
                    if (error) {
                        vscode.window.showErrorMessage(l10n.t('Merge failed: {0}', error.message));
                        console.error(`Error: ${error.message}`);
                        console.error(`Stderr: ${stderr}`);
                        reject(error);
                        return;
                    }

                    progress.report({ increment: 100, message: l10n.t('Merge completed!') });
                    
                    // Show success message
                    const outputChannel = vscode.window.createOutputChannel('tgMerge');
                    outputChannel.appendLine(stdout);
                    outputChannel.show(true);
                    
                    const baseFileName = path.basename(mergeFilePath);
                    vscode.window.showInformationMessage(l10n.t('Home Assistant Blueprint merged successfully: {0}', baseFileName));
                    resolve();
                });
            });
        });
    });

    context.subscriptions.push(disposable);

    // Optional: Add status bar item
    const statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
    statusBarItem.command = 'tgMerge.saveAndMerge';
    statusBarItem.text = l10n.t('$(merge) Merge');
    statusBarItem.tooltip = l10n.t('Save & Merge Home Assistant Blueprint');
    
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











