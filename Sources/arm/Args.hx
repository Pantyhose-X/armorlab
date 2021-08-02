package arm;

import arm.sys.Path;
import arm.sys.File;
import arm.io.ExportTexture;
import arm.io.ImportAsset;
import arm.io.ImportArm;
import arm.ui.BoxExport;
import arm.Enums;

class Args {

	static var useArgs = false;
	static var assetPath = "";
	static var exportTextures = false;
	static var exportTexturesType = "";
	static var exportTexturesPreset = "";
	static var exportTexturesPath = "";
	static var background = false;

	public static function parse() {
		if (Krom.getArgCount() > 1) {
			useArgs = true;

			for (v in 0...Krom.getArgCount()) {
				// Process each arg
				var currentArg = Krom.getArg(v);
				if (Path.isProject(currentArg)) {
					Project.filepath = currentArg;
				}
				else if (Path.isTexture(currentArg)) {
					assetPath = currentArg;
				}
				else if (currentArg == "--export-textures" && (v + 3) <= Krom.getArgCount()) {
					exportTextures = true;
					exportTexturesType = Krom.getArg(v + 1);
					exportTexturesPreset = Krom.getArg(v + 2);
					exportTexturesPath = Krom.getArg(v + 3);
				}
				else if (currentArg == "--b" || currentArg == "--background") {
					background = true;
				}
			}
		}
	}

	public static function run() {
		if (useArgs) {
			iron.App.notifyOnInit(function() {
				if (Project.filepath != "") {
					ImportArm.runProject(Project.filepath);
				}
				else if (assetPath != "") {
					ImportAsset.run(assetPath, -1, -1, false);
				}
				else if (exportTextures) {
					if (exportTexturesType == "png" ||
						exportTexturesType == "jpg") {
						if (Path.isFolder(exportTexturesPath)) {
							// Applying the correct format type from args
							if (exportTexturesType == "png") {
								Context.formatType = FormatPng;
							}
							else if (exportTexturesType == "jpg") {
								Context.formatType = FormatJpg;
							}

							// Get export preset and apply the correct one from args
							BoxExport.files = File.readDirectory(Path.data() + Path.sep + "export_presets");
							for (i in 0...BoxExport.files.length) {
								BoxExport.files[i] = BoxExport.files[i].substr(0, BoxExport.files[i].length - 5); // Strip .json
							}

							var file = "export_presets/" + BoxExport.files[0] + ".json";
							for (f in BoxExport.files) if (f == exportTexturesPreset) {
								file = "export_presets/" + BoxExport.files[BoxExport.files.indexOf(f)] + ".json";
							}

							iron.data.Data.getBlob(file, function(blob: kha.Blob) {
								BoxExport.preset = haxe.Json.parse(blob.toString());
								iron.data.Data.deleteBlob("export_presets/" + file);
							});

							// Export queue
							function _init() {
								ExportTexture.run(exportTexturesPath);
							}
							iron.App.notifyOnInit(_init);
						}
						else {
							trace("Invalid export directory");
						}
					}
					else {
						trace("Invalid texture type");
					}
				}
				if (background) kha.System.stop();
			});
		}
	}
}
