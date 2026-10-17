source("report_generator.R");
source("analyze_multi_reports.R");

filter <- list(
	list("key"="name", "value"="Apartment", "display"="Apartment"),
	list("key"="name", "value"="Laboratory", "display"="Laboratory")
);
yLab <- expression(paste("Lambda ", lambda));
yKey <- "regularization_param";
fn <- "../results/lambda/lambda"

data <- reports_load_multi("../results/results_lambda/[AL]*");

keys <- list(
	list("key"="avgNettoMean", "display"=expression(paste("Avg. depth reconstruction error ", mu[D], " [m]"))),
	list("key"="avgNettoMedian", "display"="Median depth reconstruction error [m]"),
	list("key"="mF", "display"=expression(paste("False positives ", nu[F]))),
	list("key"="mT", "display"=expression(paste("True positives ", nu[T]))),
	list("key"="avgTime", "display"="Average runtime [ms]"),
	list("key"="meanDist", "display"=expression(paste("Avg. obstacle detection error ", mu, " [m]"))),
	list("key"="medianDist", "display"="Median obstacle detection error [m]")
);

for (entry in keys) {
	xKey <- entry$key;
	xLab <- entry$display;
	print(paste(xKey, "\n"));
	print(paste(xLab, "\n"));
	reports_plot_performance_over_param2(
		data, filter, yKey, xKey, yLab, xLab,
		paste(fn, "_", xKey, ".pdf", sep=""), TRUE, NULL, 2);
}

