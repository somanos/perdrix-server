const argparse = require("argparse");

const parser = new argparse.ArgumentParser({
	description: "perdrix db utils",
	addHelp: true,
});

parser.addArgument("--source", {
	type: String,
	help: "Source de tirage",
});

parser.addArgument("--output", {
	type: String,
	help: "Output file ",
});
parser.addArgument("--skip", {
	type: String,
	help: "Skip column",
});
parser.addArgument("--db", {
	type: String,
	required: true,
	help: "Target db name ",
});



const args = parser.parseArgs();
module.exports = args;
