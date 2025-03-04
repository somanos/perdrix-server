const argparse = require("argparse");

const parser = new argparse.ArgumentParser({
	description: "perdrix db utils",
	addHelp: true,
});

parser.addArgument("--source", {
	type: String,
	defaultValue: "../data/tirage.csv",
	help: "Source de tirage",
});

parser.addArgument("--output", {
	type: String,
	defaultValue: 0,
	help: "Output file ",
});


const args = parser.parseArgs();
module.exports = args;
