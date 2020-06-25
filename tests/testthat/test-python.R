test_that("python engines work with absolute dirs", {
  skip_if_not_installed("reticulate")
  pyf <- example_file("simple-python.Rmd")
  tmp <- make_tmp()

  expect_output(
    {
      knitr::knit(pyf, output = tmp, envir = new.env(), encoding = "UTF-8")
    },
    'engine: chr "python"',
    fixed = TRUE
  )

  txt <- paste(readLines(tmp), collapse = "\n")
  expect_match(txt, "This is some text", fixed = TRUE)
})

test_that("python engines work with relative dirs", {
  skip_if_not_installed("reticulate")
  # skip("There's something fishy about environments here")
  py1 <- provision_jekyll("simple-python.Rmd")
  expect_output(pyf <- knit_jekyll(py1), 'engine: chr "python"', fixed = TRUE)
  expect_true(file.exists(pyf))
  txt <- paste(readLines(pyf), collapse = "\n")
  expect_match(txt, "This is some text", fixed = TRUE)
})

test_that("simple python engines work with relative dirs", {
  skip_if_not_installed("reticulate")
  # skip("There's something fishy about environments here")
  py1 <- provision_jekyll("simple-python.Rmd")
  expect_output(pyf <- knit_jekyll(py1), 'engine: chr "python"', fixed = TRUE)
  expect_true(file.exists(pyf))
  txt <- paste(readLines(pyf), collapse = "\n")
  expect_match(txt, "This is some text", fixed = TRUE)
})
