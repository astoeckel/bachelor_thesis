#
# ===========================================================================
#
# analyze_multi_reports.R
#
#
# Andreas Stöckel <astoecke>
#
#    Copyright (C) 2013
#    Computer Engineering Group
#    Faculty of Technology
#    Bielefeld University
#

reports_load_multi <- function(pattern) {
	dirs <- Sys.glob(pattern);
	i <- 1;
	res <- list();
	for (dir in dirs) {
		res[[i]] <- report_load(dir);
		i <- i + 1;
	}
	res;
}

reports_filter <- function(reports, filterParam, filterValue) {
	Filter(function (x) {x$params[[filterParam]] == filterValue}, reports)
}

reports_param_value <- function(reports, paramName, valueName) {
	res <- list();
	res$x <- unlist(lapply(reports, function(x) {x$params[[paramName]]}));
	res$y <- unlist(lapply(reports, function(x) {x[[valueName]]}));
	res
}

reports_plot_performance_over_param <- function(reports, paramName, valueName) {
	# Filter by propgation matrix type
	gauss <- reports_filter(reports, "propagation_matrix_type", "gaussian");
	ones <- reports_filter(reports, "propagation_matrix_type", "ones");
	propagation <- reports_filter(reports, "propagation_matrix_type", "propagation");

	# Fetch the x-/y-data for each set
	gd <- reports_param_value(gauss, paramName, valueName);
	od <- reports_param_value(ones, paramName, valueName);
	pd <- reports_param_value(propagation, paramName, valueName);

	# Fetch the data ranges
	rangeX <- range(gd$x, od$x, pd$x);
	rangeY <- range(gd$y, od$y, pd$y);

	# Plot the data
	plot.new();
	plot.window(xlim=rangeX, ylim=rangeY);
	par(family="Times", ps=14, mar=c(5,5,5,7), mgp=c(3,1,0), xpd=FALSE);
	#report_setup_plot();
	axis(1);
	axis(2);
	title(xlab=paramName, ylab=valueName);
	box();
	grid();
	points(gd$x, gd$y, pch=1);
	lines(gd$x, gd$y, lty=1);

	points(od$x, od$y, pch=2);
	lines(od$x, od$y, lty=2);

	points(pd$x, pd$y, pch=3);
	lines(pd$x, pd$y, lty=3);

	par(xpd=TRUE);
	legend("topright", c("Gaussian", "Ones", "Propagation"),
		lty=c(1, 2, 3), pch=c(1, 2, 3), inset=c(-0.2, 0));
}

reports_plot_performance_over_param2 <- function(reports, filters, paramName,
		valueName, xLab = NULL, yLab = NULL, writePdf = FALSE, showLegend = TRUE, maxY = NULL) {
	# Filter by the given key/value and calculate the current range
	data <- list();
	rangeX <- c();
	if (is.null(maxY)) {
		rangeY <- c();
	} else {
		rangeY <- c(maxY);
	}
	i <- 1;
	legendLbl <- c();
	for (filter in filters) {
		filtered <- reports_filter(reports, filter$key, filter$value);
		d <- reports_param_value(filtered, paramName, valueName);
		rangeX <- range(rangeX, d$x);
		rangeY <- range(0, rangeY, d$y);
		indices <- sort.list(d$x);
		dOrdered <- list();
		dOrdered$x <- d$x[indices];
		dOrdered$y <- d$y[indices];
		data[[i]] <- dOrdered;
		legendLbl <- c(legendLbl, if (is.null(filter$display)) paste(filter$key, "=", filter$value) else filter$display);
		i <- i + 1;
	}
	cnt <- i;

	# Setup the plot window
	if (writePdf != FALSE) {
		pdf(writePdf, width=4.5, height=4.5);
	}
	plot.new();
	plot.window(xlim=rangeX, ylim=rangeY);
	par(family="Times", ps=14, mar=c(4,4,1,1), mgp=c(2.5,1,0), xpd=FALSE);

	# Plot the data
	i <- 1;
	for (d in data) {
		lines(d$x, d$y, lty=i);
		points(d$x, d$y, pch=i);
		i <- i + 1;
	}

	# Add the legend
	box();
	axis(1);
	axis(2);
	if (is.null(xLab)) xLab <- paramName;
	if (is.null(yLab)) yLab <- valueName;
	title(xlab=xLab, ylab=yLab);

	if (showLegend) {
		rng <- par("usr");
		w <- rng[2] - rng[1];
		h <- rng[4] - rng[3];
		mar <- 0.01;
		lg <- legend(
			rng[1], rng[2], xjust=0.5, yjust=0,
			legendLbl, lty=seq(1, cnt), pch=seq(1, cnt), bty="n",
			plot=FALSE);
		legend(rng[1] + w * mar,
			rng[4] + lg$rect$h - h * mar,
			legendLbl, lty=seq(1, cnt), pch=seq(1, cnt), bty="n");
	}

	if (writePdf != FALSE) {
		dev.off();
	}
}

reports_plot_performance_over_param_ref <- function(reports, filters, paramName, refValue,
		valueName, xLab = NULL, yLab = NULL, writePdf = FALSE, showLegend = TRUE) {
	# Filter by the given key/value and calculate the current range
	data <- list();
	refData <- list();
	rangeX <- c();
	rangeY <- c();
	i <- 1;
	legendLbl <- c();
	for (filter in filters) {
		preFiltered <- reports_filter(reports, filter$key, filter$value);
		filtered <- Filter(function (x) {x$params[[paramName]] != refValue}, preFiltered);
		d <- reports_param_value(filtered, paramName, valueName);
		filtered <- Filter(function (x) {x$params[[paramName]] == refValue}, preFiltered);
		refD <- reports_param_value(filtered, paramName, valueName);
		rangeX <- range(rangeX, d$x);
		rangeY <- range(0, rangeY, d$y, refD$y);
		indices <- sort.list(d$x);
		dOrdered <- list();
		dOrdered$x <- d$x[indices];
		dOrdered$y <- d$y[indices];
		data[[i]] <- dOrdered;
		refData[[i]] <- refD;
		legendLbl <- c(legendLbl, if (is.null(filter$display)) paste(filter$key, "=", filter$value) else filter$display);
		i <- i + 1;
	}
	cnt <- i;

	# Setup the plot window
	if (writePdf != FALSE) {
		pdf(writePdf, width=4.5, height=4.5);
	}
	plot.new();
	plot.window(xlim=rangeX, ylim=rangeY);
	par(family="Times", ps=14, mar=c(4,4,1,1), mgp=c(2.5,1,0), xpd=FALSE);

	# Plot the data
	i <- 1;
	for (d in data) {
		abline(h=refData[[i]]$y, lty=i, col="#3465a4", lwd=2);
		lines(d$x, d$y, lty=i);
		points(d$x, d$y, pch=i);
		i <- i + 1;
	}

	# Add the legend
	box();
	axis(1);
	axis(2);
	if (is.null(xLab)) xLab <- paramName;
	if (is.null(yLab)) yLab <- valueName;
	title(xlab=xLab, ylab=yLab);

	if (showLegend) {
		rng <- par("usr");
		w <- rng[2] - rng[1];
		h <- rng[4] - rng[3];
		mar <- 0.01;
		lg <- legend(
			rng[1], rng[2], xjust=0.5, yjust=0,
			legendLbl, lty=seq(1, cnt), pch=seq(1, cnt), bty="n",
			plot=FALSE);
		legend(rng[1] + w * mar,
			rng[4] + lg$rect$h - h * mar,
			legendLbl, lty=seq(1, cnt), pch=seq(1, cnt), bty="n");
	}

	if (writePdf != FALSE) {
		dev.off();
	}
}

