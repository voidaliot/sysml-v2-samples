# SysML v2 samples

Open these models with [Aliot SysML v2 for VS Code](https://marketplace.visualstudio.com/items?itemName=voidaliot.vscode-sysml-v2). See the [user guide](https://voidaliot.github.io/sysml-v2-vscext-release/user-guide.html) for editing and diagram navigation.

| Start here | Explore |
| --- | --- |
| [Small rover](aliot-first-model.sysml) | A short first model |
| [Flashlight](flashlight.sysml) | Parts, ports and connections |
| [Drone](drone.sysml) | A connected system |
| [All-view drone](aliot-all-views.sysml) | General, Interconnection, Action Flow, State Transition, Sequence, Case, Geometry and Grid views |
| [Software-defined vehicle](sdv.sysml) | A larger architecture |
| [Properties demo](release-demo-before.sysml) | Inherited values and nested subsystem navigation |

The [all-view guide](https://voidaliot.github.io/sysml-v2-vscext-release/user-guide.html#all-view-model-tour) names the anchor and editing steps for each diagram. To reproduce its presentation, copy `all-views-project.json` to `.vscode/sysml/project.json` and `all-views-layout.json` to `.vscode/sysml/diagrams/aliot-all-views.sysml.json` beside the model.

`release-demo-after.sysml` is the Properties demo after a local battery-capacity override. `workflow-before.sysml` and `workflow-after.sysml` show a rename. These are independent before/after snapshots.

For headless export, install [sysml-diagram from npm](https://www.npmjs.com/package/sysml-diagram):

```sh
npm install -g sysml-diagram
sysml-diagram export --file aliot-all-views.sysml --view iv --anchor AliotShowcase::Architecture::drone --theme light --out drone.svg
```

Use `--theme dark` for a dark SVG. Add `--auto-layout` for a new arrangement. In VS Code, **SysML: Copy Headless CLI Command** copies a command for the active diagram. Grid View supports CSV export.
