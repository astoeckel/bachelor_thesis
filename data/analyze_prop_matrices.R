source("report_generator.R");
source("analyze_multi_reports.R");

filter <- list(
	list("key"="propagation_matrix_type", "value"="gaussian", "display"="Gaussian"),
	list("key"="propagation_matrix_type", "value"="ones", "display"="Ones"),
	list("key"="propagation_matrix_type", "value"="propagation", "display"="Propagation")
);
yLab <- expression(paste("Radius ", r[W]));
yKey <- "propagation_matrix_radius";
fn <- "../results/matrices/propmat"

dataLaboratory <- reports_load_multi("../results/results_propgation_matrices/Laboratory_type*");
dataApartment <- reports_load_multi("../results/results_propgation_matrices/Apartment_type*");

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
		dataLaboratory, filter, yKey, xKey, yLab, xLab,
		paste(fn, "_laboratory_", xKey, ".pdf", sep=""));
	reports_plot_performance_over_param2(
		dataApartment, filter, yKey, xKey, yLab, xLab,
		paste(fn, "_apartment_", xKey, ".pdf", sep=""));
}

