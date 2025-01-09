#### R pkgs ####

library(bruceR)
library(rvest)


#### CRAN pkgs URLs ####

url.cran = "https://cran.r-project.org/web/packages/available_packages_by_date.html"
xml.cran = read_html(url.cran)
pkgs.name = xml.cran %>% html_elements(".CRAN") %>% html_text()
pkgs.urls = "https://cran.r-project.org/web/packages/" %^% pkgs.name %^% "/index.html"
pkgs = data.table(pkg=pkgs.name, url=pkgs.urls)[order(pkg)]
save(pkgs, file="pkgs.RData")


#### CRAN pkgs Info ####

d1 = import("pkgs.20230611.RData")
d2 = import("pkgs.20230811.RData")
d3 = import("pkgs.20231029.RData")
d = d3[pkg %notin% unique(d1$pkg, d2$pkg)]

cran_element = function(x, domain) {
  x[grep(domain %^% ":", x, fixed=TRUE) + 1]
}

cran_pkg = function(pkg) {
  xml = read_html("https://cran.r-project.org/web/packages/" %^% pkg %^% "/index.html")
  title = xml %>% html_element("h2") %>% html_text() %>% str_replace_all("\\n", " ")
  tds = xml %>% html_elements("td") %>% html_text()
  version = cran_element(tds, "Version")
  date.last = cran_element(tds, "Published")
  author = cran_element(tds, "Author") %>% str_remove_all("\\n") %>%
    str_replace_all(",", ", ") %>% str_replace_all("\\s+", " ")
  maintainer = cran_element(tds, "Maintainer") %>%
    str_replace_all(" at ", "@") %>% str_replace_all("\\s+", " ")

  updates = 1
  date.init = date.last
  try({
    xml.history = read_html("https://cran.r-project.org/src/contrib/Archive/" %^% pkg %^% "/")
    updates = xml.history %>% html_elements("td a") %>% html_text() %>% length()
    date.init = xml.history %>% html_element("tr:nth-child(4) td:nth-child(3)") %>%
      html_text() %>% str_remove(" .*")
  }, silent=TRUE)

  data.table(pkg, date.init, date.last,
             updates, version,
             maintainer, author, title)
}

for(pkg in d$pkg) {
  filename = "data/" %^% pkg %^% ".txt"
  if(!file.exists(filename)) {
    t0 = Sys.time()
    export(cran_pkg(pkg), filename)
    Print("Data saved [{pkg}] ({dtime(t0)})")  # average = 0.5 secs
    Sys.sleep(0.2)
  }
}


#### Merge Data ####

data = rbindlist(lapply(list.files("data"), function(file) {
  d = import("data/" %^% file, encoding="UTF-8")[1,]
  d$version = as.character(d$version)
  if(nchar(d$version)==1) d$version = d$version %^% ".0"
  return(d)
})) %>% as.data.table() %>% .[order(pkg)]
data$maintainer = str_remove_all(data$maintainer, "'|\"")
save(data, file="data.RData")

data = rbind(
  import("data.20230612.RData"),
  import("data.20230811.RData"),
  import("data.20231029.RData")
) %>% unique(by="pkg") %>% .[order(pkg)]
save(data, file="data.RData")


#### Maintainer Summary ####

data = import("data.RData")
dm = data[, .(pkgs=.N), keyby=maintainer]
dm[, `:=`(
  name = str_remove(maintainer, "<.*") %>% str_trim(),
  email = str_extract(maintainer, "(?<=<).*(?=>)"),
  domain = str_extract(maintainer, "\\.[^.]+(?=>)")
)]
export(dm, "maintainer.xlsx")

dm1 = import("maintainer.20230612.xlsx", as="data.table")
dm2 = import("maintainer.20230811.xlsx", as="data.table")
dm3 = import("maintainer.20231029.xlsx", as="data.table")
dm.diff = dm3[maintainer %notin% unique(dm1$maintainer, dm2$maintainer)]
export(dm.diff, "maintainer.diff.xlsx")

