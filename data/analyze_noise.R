source("report_generator.R");
source("analyze_multi_reports.R");

filter <- list(
	list("key"="name", "value"="Apartment", "display"="Apartment"),
	list("key"="name", "value"="Laboratory", "display"="Laboratory")
);
yKey <- "noise_sigma";
fn <- "../results/noise/noise"

data <- reports_load_multi("../results/results_noise/[AL]*");
dataImage <- reports_filter(data, "noise_type", "image");
dataD <- reports_filter(data, "noise_type", "d");
dataAlpha <- reports_filter(data, "noise_type", "alpha");
dataPsi <- reports_filter(data, "noise_type", "psi");

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
	yLab <- entry$display;
	print(paste(xKey, "\n"));
	print(paste(xLab, "\n"));

	reports_plot_performance_over_param2(
		dataImage, filter, yKey, xKey, expression(paste("Image variance ", sigma)), yLab,
		paste(fn, "_image_", xKey, ".pdf", sep=""), TRUE, 1.0);
	reports_plot_performance_over_param2(
		dataD, filter, yKey, xKey, expression(paste(d, " variance ", sigma, " [m]")), yLab,
		paste(fn, "_d_", xKey, ".pdf", sep=""), TRUE, 1.0);
	reports_plot_performance_over_param2(
		dataPsi, filter, yKey, xKey, expression(paste(psi, " variance ", sigma, " [rad]")), yLab,
		paste(fn, "_psi_", xKey, ".pdf", sep=""), TRUE, 1.0);
	reports_plot_performance_over_param2(
		dataAlpha, filter, yKey, xKey, expression(paste(alpha, " variance ", sigma, " [rad]")), yLab,
		paste(fn, "_alpha_", xKey, ".pdf", sep=""), TRUE, 1.0);
}

