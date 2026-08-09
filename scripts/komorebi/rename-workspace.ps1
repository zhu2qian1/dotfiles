Add-Type -AssemblyName Microsoft.VisualBasic
$name = [Microsoft.VisualBasic.Interaction]::InputBox('New workspace name', 'Rename Workspace', '')
if ($name) {
    komorebic workspace-name (komorebic query focused-monitor-index) (komorebic query focused-workspace-index) $name
}
