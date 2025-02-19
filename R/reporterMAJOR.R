reporterMAJOR <- function(x, filename, open=TRUE, digits, footnotes=FALSE, ...) {
  
#reporter.rma.uni <- function(x, dir, filename, format="html_document", open=TRUE, digits, forest, funnel, footnotes=FALSE, verbose=TRUE, ...) {


## I did not write this I took it from metafor and changed it around so I could put it in MAJOR ##
  ### WKH 10/26/2020 ###
 

  
  if (missing(digits)) {
    digits <- getdigits(xdigits=x$digits, dmiss=TRUE)
  } else {
    digits <- getdigits(digits=digits, xdigits=x$digits, dmiss=FALSE)
  }
  

  
  ### set default filenames
  
  object.name <- deparse(substitute(x))
  has.object.name <- TRUE
  
  if (grepl("rma(", object.name, fixed=TRUE) || grepl("rma.uni(", object.name, fixed=TRUE)) { # check for 'reporter(rma(yi, vi))' usage
    has.object.name <- FALSE
    object.name <- "res"
  }
  

  
  # ### process forest argument
  # 
  # plot.forest <- FALSE # I changed this
  # args.forest <- ""
  # if (!missing(forest)) {
  #   if (is.logical(forest)) {
  #     if (isFALSE(forest))
  #       plot.forest <- FALSE
  #   } else {
  #     if (!is.character(forest))
  #       stop(mstyle$stop("Argument 'forest' must be a character string."))
  #     args.forest <- paste0(", ", forest)
  #   }
  # }
  # 
  # ### process funnel argument
  # 
  # plot.funnel <- FALSE # I changed this
  # args.funnel <- ""
  # if (!missing(funnel)) {
  #   if (is.logical(funnel)) {
  #     if (isFALSE(funnel))
  #       plot.funnel <- FALSE
  #   } else {
  #     if (!is.character(funnel))
  #       stop(mstyle$stop("Argument 'funnel' must be a character string."))
  #     args.funnel <- paste0(", ", funnel)
  #   }
  # }
  
  ### forest and funnel plot numbers
  # if (plot.forest) {
  #   num.forest <- 1
  #   num.funnel <- 2
  # } else {
  #   num.forest <- NA
  #   num.funnel <- 1
  # }
  

  
  ### get measure name
  
  measure <- tolower(setlab(x$measure, transf.char=FALSE, atransf.char=FALSE, gentype=1))
  measure <- sub("observed outcome", "outcome", measure)
  measure <- sub("fisher's z", "Fisher r-to-z", measure)
  measure <- sub("yule", "Yule", measure)
  measure <- sub("freeman", "Freeman", measure)
  measure <- sub("tukey", "Tukey", measure)
  measure <- sub("log ratio of means", "response ratio", measure)
  
  ### model type
  
  model <- ifelse(x$method == "FE", ifelse(x$int.only, "FE", "MR"), ifelse(x$int.only, "RE", "ME"))
  model.name <- c(FE = "fixed-effects", MR = "(fixed-effects) meta-regression", RE = "random-effects", ME = "(mixed-effects) meta-regression")[model]
  
  ### get tau^2 estimator name and set reference
  
  tau2.method <- c(FE = "", HS = "Hunter-Schmidt", HSk = "k-corrected Hunter-Schmidt", HE = "Hedges'", DL = "DerSimonian-Laird", GENQ = "generalized Q-statistic", GENQM = "(median-unbiased) generalized Q-statistic", SJ = "Sidik-Jonkman", ML = "maximum-likelihood", REML = "restricted maximum-likelihood", EB = "empirical Bayes", PM = "Paule-Mandel", PMM = "(median-unbiased) Paule-Mandel")[x$method]
  
  if (x$method == "HS" && model == "RE")
    tau2.ref <- "(Hunter 1990 ; Viechtbauer 2005)"
  if (x$method == "HS" && model == "ME")
    tau2.ref <- "(Hunter 1990 ; Viechtbauer 2005)"
  
  if (x$method == "HSk" && model == "RE")
    tau2.ref <- "(Brannick2019; Hunter 1990; Viechtbauer 2005)"
  if (x$method == "HSk" && model == "ME")
    tau2.ref <- "(Brannick2019; Hunter 1990; Viechtbauer 2015)"
  
  if (x$method == "HE" && model == "RE")
    tau2.ref <- "(Hedges 1985)"
  if (x$method == "HE" && model == "ME")
    tau2.ref <- "(Hedges 1992)"
  
  if (x$method == "DL" && model == "RE")
    tau2.ref <- "(Dersimonian 1986)"
  if (x$method == "DL" && model == "ME")
    tau2.ref <- "(Raudenbush 2009)"
  
  if (x$method == "GENQ" && model == "RE")
    tau2.ref <- "(DerSimonian 2007)"
  if (x$method == "GENQ" && model == "ME")
    tau2.ref <- "(Jackson 2014)"
  
  if (x$method == "GENQM" && model == "RE")
    tau2.ref <- "(DerSimonian 2007)"
  if (x$method == "GENQM" && model == "ME")
    tau2.ref <- "(Jackson 2014)"
  
  if (x$method == "SJ")
    tau2.ref <- "(Sidik 2005)"
  
  if (x$method == "ML" && model == "RE")
    tau2.ref <- "(Hardy 1996)"
  if (x$method == "ML" && model == "ME")
    tau2.ref <- "(Raudenbush 2009)"
  
  if (x$method == "REML" && model == "RE")
    tau2.ref <- "(Viechtbauer 2005)"
  if (x$method == "REML" && model == "ME")
    tau2.ref <- "(Raudenbush 2009)"
  
  if (x$method == "EB" && model == "RE")
    tau2.ref <- "(Morris 1983)"
  if (x$method == "EB" && model == "ME")
    tau2.ref <- "(Berkey 1995)"
  
  if (x$method == "PM" && model == "RE")
    tau2.ref <- "(Paule 1982)"
  if (x$method == "PM" && model == "ME")
    tau2.ref <- "(Viechtbauer 2015)"
  
  if (x$method == "PMM" && model == "RE")
    tau2.ref <- "[@paule1982]"
  if (x$method == "PMM" && model == "ME")
    tau2.ref <- "(Viechtbauer 2015)"
  
  ### Q-test reference
  
  if (is.element(model, c("FE", "RE"))) {
    qtest.ref <- "(Cochran 1954)"
  } else {
    qtest.ref <- "(Hedges 1983)"
  }
  
  ### CI level
  
  level <- 100 * (1-x$level)
  
  ### Bonferroni-corrected critical value for studentized residuals
  
  crit <- qnorm(x$level/(2*x$k), lower.tail=FALSE)
  
  ### get influence results
  
  infres <- influence(x)
  
  ### formating function for p-values
  
  fpval <- function(p, pdigits=digits[["pval"]])
    paste0("p ", ifelse(p < 10^(-pdigits), paste0("< ", fcf(10^(-pdigits), pdigits)), paste0("= ", fcf(p, pdigits))), "")
  # consider giving only 2 digits for p-value if p > .05 or p > .10
  
  #########################################################################
  
  ### yaml header
  
  # header <- paste0("---\n")
  # header <- paste0(header, "output:\n")
  # if (format == "html_document")
  #   header <- paste0(header, "  html_document:\n    toc: true\n    toc_float:\n      collapsed: false\n")
  # if (format == "pdf_document")
  #   header <- paste0(header, "  pdf_document:\n    toc: true\n")
  # if (format == "word_document")
  #   header <- paste0(header, "  word_document\n")
  # header <- paste0(header, "title: Analysis Report\n")
  # header <- paste0(header, "toc-title: Table of Contents\n")
  # header <- paste0(header, "author: Generated with the reporter() Function of the metafor Package\n")
  # header <- paste0(header, "bibliography: references.bib\n")
  # header <- paste0(header, "csl: apa.csl\n")
  # header <- paste0(header, "date: \"`r format(Sys.time(), '%d %B, %Y')`\"\n")
  # header <- paste0(header, "---\n")
  
  #########################################################################
  
  ### rsetup
  
  # rsetup <- paste0("```{r, setup, include=FALSE}\n")
  # rsetup <- paste0(rsetup, "library(metafor)\n")
  # rsetup <- paste0(rsetup, "load('", file.path(dir, file.obj), "')\n")
  # rsetup <- paste0(rsetup, "```")
  
  #########################################################################
  
  ### methods section
  
  methods <- " "
  
  if (x$measure != "GEN")
    methods <- paste0(methods, "The analysis was carried out using the ", measure, " as the outcome measure. ")
  
  methods <- paste0(methods, "A ", model.name, " model was fitted to the data. ")
  
  if (is.element(model, c("RE", "ME")))
    methods <- paste0(methods, "The amount of ", ifelse(x$int.only, "", "residual "), "heterogeneity (i.e., tau\u00B2), was estimated using the ", tau2.method, " estimator ", tau2.ref, ". ")
  
  if (model == "FE")
    methods <- paste0(methods, "The Q-test for heterogeneity ", qtest.ref, " and the I\u00B2 statistic are reported. ")
  
  if (model == "MR")
    methods <- paste0(methods, "The Q-test for residual heterogeneity ", qtest.ref, " is reported. ")
  
  if (model == "RE")
    methods <- paste0(methods, "In addition to the estimate of tau\u00B2, the Q-test for heterogeneity ", qtest.ref, " and the I\u00B2 statistic are reported. ")
  
  if (model == "ME")
    methods <- paste0(methods, "In addition to the estimate of tau\u00B2, the Q-test for residual heterogeneity ", qtest.ref, " is reported. ")
  
  if (model == "RE")
    methods <- paste0(methods, "In case any amount of heterogeneity is detected (i.e., tau\u00B2 > 0, regardless of the results of the Q-test), a prediction interval for the true outcomes is also provided. ")
  
  if (x$test == "knha")
    methods <- paste0(methods, "Tests and confidence intervals were computed using the Knapp and Hartung method. ")
  
  methods <- paste0(methods, "Studentized residuals and Cook's distances are used to examine whether studies may be outliers and/or influential in the context of the model. ")
  
  #methods <- paste0(methods, "Studies with a studentized residual larger than $\\pm 1.96$ are considered potential outliers. ")
  methods <- paste0(methods, "Studies with a studentized residual larger than the 100 x (1 - ", x$level, "/(2 X k))th percentile of a standard normal distribution are considered potential outliers (i.e., using a Bonferroni correction with two-sided alpha = ", x$level, " for k studies included in the meta-analysis). ") # $\\pm ", fcf(crit, digits[["test"]]), "$ (
  
  #methods <- paste0(methods, "Studies with a Cook's distance larger than ", fcf(qchisq(0.5, df=infres$m), digits[["test"]]), " (the 50th percentile of a $\\chi^2$-distribution with ", infres$m, " degree", ifelse(infres$m > 1, "s", ""), " of freedom) are considered to be influential. ")
  methods <- paste0(methods, "Studies with a Cook's distance larger than the median plus six times the interquartile range of the Cook's distances are considered to be influential.")
  
  methods <- if (footnotes) paste0(methods, "[^cook] ") else paste0(methods, " ")
  
  if (is.element(model, c("FE", "RE")))
    methods <- paste0(methods, "The rank correlation test and the regression test, using the standard error of the observed outcomes as predictor, are used to check for funnel plot asymmetry. ")
  
  if (is.element(model, c("MR", "ME")))
    methods <- paste0(methods, "The regression test, using the standard error of the observed outcomes as predictor (in addition to the moderators already included in the model), is used to check for funnel plot asymmetry. ")
  
  #########################################################################
  
  ### results section
  
  # results <- "\n## Results\n\n"
  #results <- " Results \n"
  ### number of studies
  results <- paste0("A total of k=", x$k, " studies were included in the analysis. ")
  
  ### range of observed outcomes
  results <- paste0(results, "The observed ", measure, "s ranged from ", fcf(min(x$yi), digits[["est"]]), " to ", fcf(max(x$yi), digits[["est"]]), ", ")
  
  ### percent positive/negative
  results <- paste0(results, "with the majority of estimates being ", ifelse(mean(x$yi > 0) > .50, "positive", "negative"), " (", ifelse(mean(x$yi > 0) > .50, round(100*mean(x$yi > 0)), round(100*mean(x$yi < 0))), "%). ")
  
  if (is.element(model, c("FE", "RE"))) {
    
    ### estimated average outcome with CI
    results <- paste0(results, "The estimated average ", measure, " based on the ", model.name, " model was ", ifelse(model == "FE", "\\hat{\\theta} = ", "\\hat{\\mu} = "), fcf(c(x$beta), digits[["est"]]), " ")
    results <- paste0(results, "(", level, "% CI: ", fcf(x$ci.lb, digits[["ci"]]), " to ", fcf(x$ci.ub, digits[["ci"]]), "). ")
    
    ### note: for some outcome measures (e.g., proportions), the test H0: mu/theta = 0 is not really relevant; maybe check for this
    results <- paste0(results, "Therefore, the average outcome ", ifelse(x$pval > 0.05, "did not differ", "differed"), " significantly from zero (", ifelse(x$test == "z", "z", paste0("t(", x$k-1, ")")), " = ", fcf(x$zval, digits[["test"]]), ", ", fpval(x$pval), "). ")
    
    # ### forest plot
    # if (plot.forest) {
    #   results <- paste0(results, "A forest plot showing the observed outcomes and the estimate based on the ", model.name, " model is shown in Figure ", num.forest, ".\n\n")
    #   if (is.element(format, c("pdf_document", "bookdown::pdf_document2")))
    #     results <- paste0(results, "```{r, forestplot, echo=FALSE, fig.align=\"center\", fig.cap=\"Forest plot showing the observed outcomes and the estimate of the ", model.name, " model\"")
    #   if (format == "html_document")
    #     results <- paste0(results, "```{r, forestplot, echo=FALSE, fig.align=\"center\", fig.cap=\"Figure ", num.forest, ": Forest plot showing the observed outcomes and the estimate of the ", model.name, " model\"")
    #   if (format == "word_document")
    #     results <- paste0(results, "```{r, forestplot, echo=FALSE, fig.cap=\"Figure ", num.forest, ": Forest plot showing the observed outcomes and the estimate of the ", model.name, " model\"")
    #   results <- paste0(results, ", dev.args=list(pointsize=9)}\npar(family=\"mono\")\npar(mar=c(5,4,1,2))\ntmp <- metafor::forest(x, addpred=TRUE, header=TRUE", args.forest, ")\n```")
    #   #text(tmp$xlim[1], x$k+2, \"Study\", pos=4, font=2, cex=tmp$cex)\ntext(tmp$xlim[2], x$k+2, \"Outcome [", level, "% CI]\", pos=2, font=2, cex=tmp$cex)\n
    # }
    
    results <- paste0(results, "\n\n")
    
    ### test for heterogeneity
    if (x$QEp > 0.10)
      results <- paste0(results, "According to the Q-test, there was no significant amount of heterogeneity in the true outcomes ")
    if (x$QEp > 0.05 && x$QEp <= 0.10)
      results <- paste0(results, "The Q-test for heterogeneity was not significant, but some heterogeneity may still be present in the true outcomes ")
    if (x$QEp <= 0.05)
      results <- paste0(results, "According to the Q-test, the true outcomes appear to be heterogeneous ")
    results <- paste0(results, "(Q(", x$k-1, ") = ", fcf(x$QE, digits[["test"]]), ", ", fpval(x$QEp))
    
    ### tau^2 estimate (only for RE models)
    if (model == "RE")
      results <- paste0(results, ", tau\u00B2 = ", fcf(x$tau2, digits[["var"]]), "")
    
    ### I^2 statistic
    results <- paste0(results, ", I\u00B2 = ", fcf(x$I2, digits[["het"]]), "%). ")
    
    ### for the RE model, when any amount of heterogeneity is detected, provide prediction interval and note whether the directionality of effects is consistent or not
    if (model == "RE" && x$tau2 > 0) {
      pred <- predict(x)
      results <- paste0(results, "A ", level, "% prediction interval for the true outcomes is given by ", fcf(pred$pi.lb, digits[["ci"]]), " to ", fcf(pred$pi.ub, digits[["ci"]]), ". ")
      if (c(x$beta) > 0 && pred$pi.lb < 0)
        results <- paste0(results, "Hence, although the average outcome is estimated to be positive, in some studies the true outcome may in fact be negative.")
      if (c(x$beta) < 0 && pred$pi.ub > 0)
        results <- paste0(results, "Hence, although the average outcome is estimated to be negative, in some studies the true outcome may in fact be positive.")
      if ((c(x$beta) > 0 && pred$pi.lb > 0) || (c(x$beta) < 0 && pred$pi.ub < 0))
        results <- paste0(results, "Hence, even though there may be some heterogeneity, the true outcomes of the studies are generally in the same direction as the estimated average outcome.")
    }
    
    results <- paste0(results, "\n\n")
    
    ### check if some studies have very large weights relatively speaking
    largeweight <- weights(x)/100 >= 3 / x$k
    if (any(largeweight)) {
      if (sum(largeweight) == 1)
        results <- paste0(results, "One study (", names(largeweight)[largeweight], ") had a relatively large weight ")
      if (sum(largeweight) == 2)
        results <- paste0(results, "Two studies (", paste(names(largeweight)[largeweight], collapse="; "), ") had relatively large weights ")
      if (sum(largeweight) >= 3)
        results <- paste0(results, "Several studies (", paste(names(largeweight)[largeweight], collapse="; "), ") had relatively large weights ")
      results <- paste0(results, "compared to the rest of the studies (i.e., \\mbox{weight} \\ge 3/k, so a weight at least 3 times as large as having equal weights across studies). ")
    }
    
    ### check for outliers
    zi <- infres$inf$rstudent
    abszi <- abs(zi)
    results <- paste0(results, "An examination of the studentized residuals revealed that ")
    if (all(abszi < crit, na.rm=TRUE))
      results <- paste0(results, "none of the studies had a value larger than \u00B1 ", fcf(crit, digits[["test"]]), " and hence there was no indication of outliers ")
    if (sum(abszi >= crit, na.rm=TRUE) == 1)
      results <- paste0(results, "one study (", infres$inf$slab[abszi >= crit & !is.na(abszi)], ") had a value larger than \u00B1 ", fcf(crit, digits[["test"]]), " and may be a potential outlier ")
    if (sum(abszi >= crit, na.rm=TRUE) == 2)
      results <- paste0(results, "two studies (", paste(infres$inf$slab[abszi >= crit & !is.na(abszi)], collapse="; "), ") had values larger than \u00B1 ", fcf(crit, digits[["test"]]), " and may be potential outliers ")
    if (sum(abszi >= crit, na.rm=TRUE) >= 3)
      results <- paste0(results, "several studies (", paste(infres$inf$slab[abszi >= crit & !is.na(abszi)], collapse="; "), ") had values larger than \u00B1 ", fcf(crit, digits[["test"]]), " and may be potential outliers ")
    results <- paste0(results, "in the context of this model. ")
    
    ### check for influential cases
    #is.infl <- pchisq(infres$inf$cook.d, df=1) > .50
    is.infl <- infres$inf$cook.d > median(infres$inf$cook.d, na.rm=TRUE) + 6 * IQR(infres$inf$cook.d, na.rm=TRUE)
    results <- paste0(results, "According to the Cook's distances, ")
    if (all(!is.infl, na.rm=TRUE))
      results <- paste0(results, "none of the studies ")
    if (sum(is.infl, na.rm=TRUE) == 1)
      results <- paste0(results, "one study (", infres$inf$slab[is.infl & !is.na(abszi)], ") ")
    if (sum(is.infl, na.rm=TRUE) == 2)
      results <- paste0(results, "two studies (", paste(infres$inf$slab[is.infl & !is.na(abszi)], collapse="; "), ") ")
    if (sum(is.infl, na.rm=TRUE) >= 3)
      results <- paste0(results, "several studies (", paste(infres$inf$slab[is.infl & !is.na(abszi)], collapse="; "), ") ")
    results <- paste0(results, "could be considered to be overly influential.")
    
    results <- paste0(results, "\n\n")
    
    ### publication bias
    ranktest <- suppressWarnings(ranktest(x))
    regtest  <- regtest(x)
    # if (plot.funnel)
    #   results <- paste0(results, "A funnel plot of the estimates is shown in Figure ", num.funnel, ". ")
    if (ranktest$pval > .05 && regtest$pval > .05) {
      results <- paste0(results, "Neither the rank correlation nor the regression test indicated any funnel plot asymmetry ")
      results <- paste0(results, "(", fpval(ranktest$pval), " and ", fpval(regtest$pval), ", respectively). ")
    }
    if (ranktest$pval <= .05 && regtest$pval <= .05) {
      results <- paste0(results, "Both the rank correlation and the regression test indicated potential funnel plot asymmetry ")
      results <- paste0(results, "(", fpval(ranktest$pval), " and ", fpval(regtest$pval), ", respectively). ")
    }
    if (ranktest$pval > .05 && regtest$pval <= .05)
      results <- paste0(results, "The regression test indicated funnel plot asymmetry (", fpval(regtest$pval), ") but not the rank correlation test (", fpval(ranktest$pval), "). ")
    if (ranktest$pval <= .05 && regtest$pval > .05)
      results <- paste0(results, "The rank correlation test indicated funnel plot asymmetry (", fpval(ranktest$pval), ") but not the regression test (", fpval(regtest$pval), "). ")
    
    ### funnel plot
    # if (plot.funnel) {
    #   if (is.element(format, c("pdf_document", "bookdown::pdf_document2")))
    #     results <- paste0(results, "\n\n```{r, funnelplot, echo=FALSE, fig.align=\"center\", fig.cap=\"Funnel plot\", dev.args=list(pointsize=9)}\npar(mar=c(5,4,2,2))\nmetafor::funnel(x", args.funnel, ")\n```")
    #   if (format == "html_document")
    #     results <- paste0(results, "\n\n```{r, funnelplot, echo=FALSE, fig.align=\"center\", fig.cap=\"Figure ", num.funnel, ": Funnel plot\", dev.args=list(pointsize=9)}\npar(mar=c(5,4,2,2))\nmetafor::funnel(x", args.funnel, ")\n```")
    #   if (format == "word_document")
    #     results <- paste0(results, "\n\n```{r, funnelplot, echo=FALSE, fig.cap=\"Figure ", num.funnel, ": Funnel plot\", dev.args=list(pointsize=9)}\npar(mar=c(5,4,2,2))\nmetafor::funnel(x", args.funnel, ")\n```")
    # }
    
  }
  
  if (is.element(model, c("MR", "ME"))) {
    
    if (x$int.incl) {
      mods <- colnames(x$X)[-1]
      p <- x$p - 1
    } else {
      mods <- colnames(x$X)
      p <- x$p
    }
    
    results <- paste0(results, "The meta-regression model included ", p, " predictor", ifelse(p > 1, "s ", " "))
    if (p == 1)
      results <- paste0(results, "(i.e., '", mods, "').")
    if (p == 2)
      results <- paste0(results, "(i.e., '", mods[1], "' and '", mods[2], "').")
    if (p >= 3)
      results <- paste0(results, "(i.e., ", paste0("'", mods[-p], "'", collapse=", "), " and ", mods[p], ").")
    
  }
  
  reportOUTPUT <- list(methods, results)
  return(reportOUTPUT)

  
}