test_that("is_real_sha works", {

  real_sha <- "7ef575ab812a189d2869e21bd11ac8f7ecd6bc81"
  fake_sha <- "1.2.3"

  expect_false(is_real_sha(fake_sha))
  expect_true(is_real_sha(real_sha))
  expect_false(is_real_sha(NA))
  expect_false(is_real_sha(NULL))
  expect_false(is_real_sha(character(0)))

})
