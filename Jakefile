/*
 * Jakefile
 * MCResource
 *
 */

var ENV = require("system").env,
    FILE = require("file"),
	OS = require("os"),
	JAKE = require("jake"),
    task = JAKE.task,
    CLEAN = require("jake/clean").CLEAN,
    FileList = JAKE.FileList,
    stream = require("narwhal/term").stream,
    framework = require("cappuccino/jake").framework,
    configuration = ENV["CONFIG"] || ENV["CONFIGURATION"] || ENV["c"] || "Release";

framework ("MCResource", function(task)
{
    task.setBuildIntermediatesPath(FILE.join("Build", "MCResource.build", configuration));
    task.setBuildPath(FILE.join("Build", configuration));

    task.setProductName("MCResource");
    task.setIdentifier("de.monkeyandco.MCResource");
    task.setVersion("1.0");
    task.setAuthor("Joachim Garth");
    task.setEmail("team @nospam@ monkeyandco.de");
    task.setSummary("MCResource");
    task.setSources(new FileList("Framework/MCResource/*.j"));
    task.setInfoPlistPath("Info.plist");

    // -T flag added to Objective-J compiler to include type signature
    // https://github.com/ternarylabs/cappuccino/commit/70432f0198622820b7652996208ed32ea96293bc
    if (configuration === "Debug")
        task.setCompilerFlags("-DDEBUG -g -T");
    else
        task.setCompilerFlags("-O -T");
});

task("build", ["MCResource"]);

task("debug", function()
{
    ENV["CONFIG"] = "Debug"
    JAKE.subjake(["."], "build", ENV);
});

task("release", function()
{
    ENV["CONFIG"] = "Release"
    JAKE.subjake(["."], "build", ENV);
});

task ("test", function()
{
    var tests = new FileList('Tests/*Test.j');
    var cmd = ["ojtest"].concat(tests.items());
    var cmdString = cmd.map(OS.enquote).join(" ");

    var code = OS.system(cmdString);
    if (code !== 0)
        OS.exit(code);
});
