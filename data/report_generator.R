#
# ===========================================================================
#
# report_generator.R
#
#
# Andreas Stöckel <astoecke>
#
#    Copyright (C) 2013
#    Computer Engineering Group
#    Faculty of Technology
#    Bielefeld University
#

report_load <- function(dir) {
	result <- list();

	# Read report etc.
	result$report <- read.csv(paste(dir, "/report.csv", sep=""));
	result$hist_detToRef <- read.csv(paste(dir, "/hist_detToRef.csv", sep=""));
	result$hist_refToDet <- read.csv(paste(dir, "/hist_refToDet.csv", sep=""));

	# Supress rows with invalid data in the report
	result$report <- result$report[complete.cases(result$report), ];

	# Read the parameters and convert them into a list
	result$params <- list();
	table <- read.table(paste(dir, "/parameters.txt", sep=""), sep="=",
			col.names=c("key", "value"), row.names=1, header=FALSE);
	for (key in rownames(table)) {
		val <- levels(droplevels(table[key,]));
		if (suppressWarnings(!is.na(as.numeric(val)))) {
			result$params[[key]] <- as.numeric(val);
		} else {
			result$params[[key]] <- val;
		}
	}
	
	# Add some of the results to the top level for convenience
	thresh <- 0.15;
	result$detectedCnt = length(result$hist_detToRef$err);
	result$referenceCnt = length(result$hist_refToDet$err);
	result$falsePositive = length(result$hist_detToRef$err[result$hist_detToRef$err > thresh]);
	result$falseNegative = length(result$hist_refToDet$err[result$hist_refToDet$err > thresh]);
	result$meanDist = mean(result$hist_detToRef$err);
	result$medianDist = median(result$hist_detToRef$err);
	result$avgBruttoMedian <- mean(result$report$depth.brutto.median);
	result$avgBruttoMean <- mean(result$report$depth.brutto.mean);
	result$avgNettoMedian <- mean(result$report$depth.netto.median);
	result$avgNettoMean <- mean(result$report$depth.netto.mean);
	result$avgTime <- mean(result$report$time.total);
	result$mF <- length(result$hist_detToRef$err[result$hist_detToRef$err > thresh]) / length(result$hist_detToRef$err);
	result$mT <- length(result$hist_detToRef$err[result$hist_detToRef$err <= thresh]) / length(result$hist_refToDet$err);

	result
}

report_param <- function(report, param) {
	report$params[[param]]
}

report_setup_plot <- function() {
	par(family="Times", ps=11, mar=c(4,4,0.5,0.5), lwd=0.75, cex=0.8, mgp=c(2,1,0));
}

report_plot_overview <- function(report, dir=".", fullLegend = TRUE) {
	# Some variables for convenient access to the report data
	rep <- report$report;
	dtr <- report$hist_detToRef;
	rtd <- report$hist_refToDet;

	# Fetch the x- and y-coordinates of the trajectory
	tx <- rep$trajectory.x;
	ty <- rep$trajectory.y;

	# Fetch the x- and y-coordinates of all detected and reference points
	dx <- dtr$x;
	dy <- dtr$y;
	derr <- dtr$err;
	rx <- rtd$x;
	ry <- rtd$y;
	rerr <- rtd$err;

	# Fetch the output range
	rangeX <- range(tx, dx, rx);
	rangeY <- range(ty, dy, ry);
	rangeY[2] <- rangeY[2] + (rangeY[2] - rangeY[1]) * 0.1;

	# Draw the overview diagram
#	pdf(paste(dir, "/overview.pdf", sep=""), width=5, height=4.5);
	pdf(paste(dir, "/overview.pdf", sep=""), width=3, height=3);
	report_setup_plot();
	plot.new();
	plot.window(xlim=rangeX, ylim=rangeY, asp=1);

	axis(1, at=-10:10);
	axis(2, at=-10:10);

#	abline(h=-10:10, v=-10:10, col="gray", lty=3);
	box();
	title(xlab="x [m]", ylab="y [m]");

#	pushViewport(viewport(x=0.558,y=0.525,width=0.783,height=0.783));
#	grid.picture(img);
#	popViewport();

	points(rx, ry, pch=ifelse(rerr < 0.15, 3, 0), col="#f57900", cex=0.8);
	points(dx, dy, pch=ifelse(derr < 0.15, 1, 16), col="#3465a4", cex=0.8);
	lines(tx, ty);

	# Draw the legend
	r <- par("usr");
	lx <- r[1] + (r[2] - r[1]) / 2;
	ly <- r[4] + (r[3] - r[4]) * 0.02;
	if (fullLegend) {
		legend(x=lx, y=ly, xjust=0.5, yjust=1, bg="white", horiz=TRUE, c(
				"Trajectory",
				"Detected",
				"False pos.",
				"Reference",
				"False neg."),
				lty=c(1, 0, 0, 0, 0),
				pch=c(NA, 1, 16, 3, 0),
				cex=0.9,
				col=c("black", "#3465a4", "#3465a4", "#f57900", "#f57900"),
				);
	} else {
		legend(x=lx, y=ly, xjust=0.5, yjust=1, bg="white", horiz=TRUE, c(
				"Trajectory",
				"Detected"),
				lty=c(1, 0),
				pch=c(NA, 1),
				cex=0.9,
				col=c("black", "#3465a4"),
				);
	}

	dev.off();
}

report_plot_single_historgram <- function(title, color, h, rx, data, app) {
	# True/False negative threshold
	thresh = 0.15;

	# Fetch some statistic to be printed
	cnt = length(data$err);
	falseCnt = length(data$err[data$err > thresh]);
	meanDist = mean(data$err);
	medianDist = median(data$err);

	# Start a pdf
	plot(h, col=color, xlim=rx, main=NULL, xlab=title);
	abline(v=thresh, col="black", lty=2);
	abline(v=meanDist, col="#4e9a06", lwd=2.0);
	abline(v=medianDist, col="#5c3566", lwd=2.0);
	legend("topright", legend=c(
			paste("Total count:", cnt),
			paste("False", app, ":", falseCnt),
			as.expression(substitute(paste("Mean distance ", italic(mu), ": ", nn, "m"), list(nn=format(meanDist, digits=3)))),
			as.expression(substitute(paste("Median distance ", italic(M), ": ", nn, "m"), list(nn=format(medianDist, digits=3))))),
			lty=c(0,0,1,1),
			col=c("black", "black", "#4e9a06", "#5c3566"),
			lwd=c(0,0,2,2),
			cex=0.9,
			bty="n");
}

report_plot_histogram <- function(report, dir=".") {
	# Fetch some values from the record for convenience
	dtrErr <- report$hist_detToRef$err;
	rtdErr <- report$hist_refToDet$err;

	# Calculate the histograms
	rx <- range(0, dtrErr, rtdErr);
	stepsize <- 0.5 / 40;
	br <- seq(rx[1], rx[2] + stepsize, stepsize);
	p1 <- hist(dtrErr, plot=FALSE, breaks=br);
	p2 <- hist(rtdErr, plot=FALSE, breaks=br);

	# Render the histograms
	pdf(paste(dir, "/histogram.pdf", sep=""), width=5, height=1.75);
	par(mfrow=c(1, 1));
	report_setup_plot();
	report_plot_single_historgram(expression(paste("Distance for each reconstructed ", italic(bar(p)) %in% P[R], " to the nearest ground truth point ", italic(bar(q)) %in% P[T], " [m]")), "#3465a4",
			p1, c(0, 0.5), report$hist_detToRef, "positives");
#	report_plot_single_historgram(expression(paste("Nearest distance: ground truth ", P[T], " to reference ", P[R], " [m]")), "#f57900",
#			p2, c(0, 0.5), report$hist_refToDet, "negatives");
	dev.off();
}

report_plot_timeline <- function(report, dir=".") {
	# Fetch some values from the record for convenience
	ts <- report$report$timestamp / 1000.0;
	avgDepth <- report$report$depth.average;
	medianErr <- report$report$depth.netto.median;
	meanErr <- report$report$depth.netto.mean;
	avgMedian <- mean(medianErr);
	avgMean <- mean(meanErr);

	# Fetch the plot range
	rangeX = range(ts);
	rangeY = range(0, avgDepth * 1.10, medianErr * 1.10, meanErr * 1.10);

	pdf(paste(dir, "/timeline.pdf", sep=""), width=5, height=3.5);
	report_setup_plot();
	plot.new();
	plot.window(xlim=rangeX, ylim=rangeY, xaxs="i", yaxs="i");
	axis(1);
	axis(2);
	grid();
	box();
	title(xlab="Time [s]", ylab="[m]");
	lines(ts, avgDepth, col="#f57900");
	lines(ts, medianErr, col="#3465a4", lty=2);
	lines(ts, meanErr, col="#3465a4");
	abline(h=avgMedian, col="#3465a4", lty=2);
	abline(h=avgMean, col="#3465a4");

	# Draw the legend
	r <- par("usr");
	lx = r[1] + (r[2] - r[1]) / 2;
	ly = r[4] + (r[3] - r[4]) * 0.02;
	legend(x=lx, y=ly, xjust=0.5, yjust=1, bty="n", horiz=TRUE, c(
			"Average depth",
			"Mean error",
			"Median error"),
			lty=c(1, 1, 2),
			cex=0.9,
			col=c("#f57900", "#3465a4", "#3465a4")
			);

	dev.off();
}

escapelatex <- function(s) {
	gsub("_", "\\_", s, fixed=TRUE);
}

report_generate_tex <- function(report, dir=".") {
	# Fetch all values
	#name <- escapelatex(gsub(".*/([a-zA-Z0-9_]*)/.*.csv", "\\1", report_param(report, "csv")));
	name <- report_param(report, "name");
	prop_type <- report_param(report, "propagation_matrix_type");
	prop_radius <- report_param(report, "propagation_matrix_radius");
	levels <- report_param(report, "error_stack_levels");
	min_dv <- report_param(report, "min_ds");
	regularization_steps <- report_param(report, "regularization_steps");
	regularization_param <- report_param(report, "regularization_param");
	energy <- report_param(report, "map_particle_energy");
	bias <- report_param(report, "error_stack_bias");
	biasFunc <- ifelse(report_param(report, "error_stack_bias_exponential") == 1, "exp", "lin");
	thresh <- 0.15;
	detectedCnt = length(report$hist_detToRef$err);
	referenceCnt = length(report$hist_refToDet$err);
	falsePositive = length(report$hist_detToRef$err[report$hist_detToRef$err > thresh]);
	falseNegative = length(report$hist_refToDet$err[report$hist_refToDet$err > thresh]);
	meanDist = mean(report$hist_detToRef$err);
	medianDist = median(report$hist_detToRef$err);

	avgBruttoMedian <- mean(report$report$depth.brutto.median);
	avgBruttoMean <- mean(report$report$depth.brutto.mean);
	avgNettoMedian <- mean(report$report$depth.netto.median);
	avgNettoMean <- mean(report$report$depth.netto.mean);

	# Output the file
	sink(paste(dir, "/report.tex", sep=""));
	# Write the header
	cat("\\documentclass[11pt]{article}\
\\usepackage[utf8]{inputenc}\
\\usepackage{graphicx}\
\\usepackage{array}\
\\usepackage[left=0cm,right=0cm,top=0cm,bottom=0cm,paperwidth=13cm,paperheight=20.7cm]{geometry}\
\
\\setlength{\\parindent}{0cm}\
\\setlength{\\parskip}{.5cm}\
\
\\begin{document}\
\\textbf{Obstacle map}\\\\\
\\includegraphics{overview.pdf}\\\\\
\\textbf{Obstacle detection histogram}\\\\\
\\includegraphics{histogram.pdf}\\\\\
\
\\pagebreak\
\
\\textbf{Netto depth reconstruction error}\\\\\
\\includegraphics{timeline.pdf}\
\
\\textbf{Parameters}\
\
\\begin{tabular}{\
		p{0.14\\textwidth}\
		p{0.3\\textwidth} |\
		p{0.33\\textwidth}\
		p{0.11\\textwidth}}\
	Scene: &", name, "& Error stack layers: & $", levels, "$ \\tabularnewline\
	\\hline\
	$W^{\\vec p}$ type: & ", prop_type," & $W^{\\vec p}$ radius $r$: & $", prop_radius, "$ \\tabularnewline\
	\\hline\
	Min. $d_v$: & $", min_dv, "$ & Particle energy: & $", energy, "$ \\tabularnewline\
	\\hline\
	$\\lambda$: & $", regularization_param, "$  & Regularization steps: & $", regularization_steps, "$ \\tabularnewline\
	\\hline\
	Bias: & $", bias, "$ & Bias function: & ", biasFunc, " \\tabularnewline\
\\end{tabular}\
\
\\textbf{Obstacle detection results}\
\
\\begin{tabular}{\
		m{0.33\\textwidth}\
		m{0.11\\textwidth} |\
		m{0.33\\textwidth}\
		m{0.11\\textwidth}}\
	Detected count:	& $", detectedCnt, "$	& Reference count:	& $", referenceCnt, "$ \\tabularnewline\
	\\hline\
	False positives:	& $", falsePositive, "$	& False negatives:	& $", falseNegative , "$ \\tabularnewline\
	\\hline\
	Mean distance: \\newline\
	\\begin{footnotesize}(detected to nearest reference)\\end{footnotesize}	& $", format(meanDist, digits=3),"\\;\\mathrm{m}$ &\
	Median distance: \\newline\
	\\begin{footnotesize}(detected to nearest reference)\\end{footnotesize} & $", format(medianDist, digits=3),"\\;\\mathrm{m}$\
\\end{tabular}\
\
\\textbf{Average depth reconstruction error}\
\
\\begin{center}\
	\\begin{tabular}{p{0.125\\textwidth} | p{0.125\\textwidth} | p{0.125\\textwidth} | p{0.125\\textwidth}}\
		\\multicolumn{2}{c|}{Brutto} & \\multicolumn{2}{c}{Netto} \\tabularnewline\
		\\hline\
		\\centering Mean & \\centering Median & \\centering Mean & \\centering Median \\tabularnewline\
		\\hline\
		\\centering $", format(avgBruttoMean, digits=3), "\\;\\mathrm{m}$ & \\centering $", format(avgBruttoMedian, digits=3), "\\;\\mathrm{m}$ & \\centering $", format(avgNettoMean, digits=3), "\\;\\mathrm{m}$ & \\centering $", format(avgNettoMedian, digits=3), "\\;\\mathrm{m}$\
	\\end{tabular}\
\\end{center}\
\\end{document}");
	sink();
}

report_generate_all <- function(dir) {
	report <- report_load(dir);
	report_plot_overview(report, dir);
	report_plot_histogram(report, dir);
	report_plot_timeline(report, dir);
	report_generate_tex(report, dir);
}

