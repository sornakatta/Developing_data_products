#ui.R
library(shiny)
library(ggplot2)

data <- read.table("./Gelman-death_trends/births.txt", header = T)



shinyUI(fluidPage(
        navbarPage("Coursera Developing Data Products MOOC"
        ),
        titlePanel("The truth wears off. . . A look at mistakes made by data scientists."),
        sidebarLayout(
                sidebarPanel(
                             h4('Adjusting the data'),
                             selectInput('Adjustment', 'Adjustment', c("Unadjusted","Age adjusted","Split by gender"), selected = "Unadjusted"),
                             strong('Description of adjustments'),
                             p("Unadjusted - Raw data as presented by Case and Deaton, 2015"),
                             p("Age Adjusted - Adjusts for the fact that the average age is increasing in the unadjusted plot, thus increasing mortality."),
                             p("Split by gender - Splits the age adjusted data by gender, showing that the increase in mortality is driven by females")
                ),
                mainPanel(
                        h3('Statistical artefacts arising from errors in data analysis'),
                          p('Note that this is a very basic App developed for the purpose of learning how to deploy an app. So nothing fancy going on here.'),
                          p("The object of the app is to visualize how biases in the analysis of data can influence the plot, and consequently the interpretation of it.
                            This is possibly of interest to fellow MOOC-ers. To illustrate this, a recently published paper written by two Princeton economists is highlighted"),
                        tags$a(href="http://www.pnas.org/content/early/2015/10/29/1518393112.full.pdf", "A. Case and A.Deaton, PNAS, 2015"),
                        p("You don't have to read the whole paper to use the app, fortunately! This article summarizes the key results."),
                        a("http://www.vox.com/2015/11/3/9663478/white-americans-mortality"),
                          p('An even shorter version is this: Case and Deaton studied the evolution of mortality rates for different ethnic groups in the US over time. Mortality rates were
                            expected to decrease (due to better healthcare, more awareness etc). In most cases, this was found to be true. However, surprisingly, mid-life (ages 45-54) white americans were an outlier to this trend.'),
                        tags$a(href="http://andrewgelman.com/wp-content/uploads/2015/11/Screen-Shot-2015-11-05-at-7.53.11-PM.png", "This is the key figure, excerpted from the paper"),
                        p("It shows how mortality rate evolution for american non-whites (USH) mirrors that of similar countries (FRA, GER, UK, CAN, AUS, SWE), but the mortality rates among 
                          american whites (USW) drastically increased over the same time period. This paper received a lot of press due to to this counterintuitive result."),
                        h4("Probing the data"),
                        p("Andrew Gelman, a statistician at Columbia, found that the results did not hold under scrutiny. In particular, he found that:"),
                        tags$ul(
                                tags$li('When adjusted for age, the differences decrease'),
                                tags$li('When adjusted for gender, the remaining difference is mainly about women')
                                                       ),
                        p("The raw data is shown below. Using the widget on the left, you can re-create Gelman's analysis and see the changes for yourself."),
                        tags$a(href = "http://www.slate.com/articles/health_and_science/science/2015/11/death_rates_for_white_middle_aged_americans_are_not_increasing.html", "Link to Gelman's article on his analysis, which includes other plots and insights."),
                        plotOutput('plot')
                                                                 
                )
#                tabPanel('data', dataTableOutput('mytable1'))
        )
)
)