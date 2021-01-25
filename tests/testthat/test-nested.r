context('submodules')

test_that('submodules can be loaded one by one', {
    on.exit(clear_mods())

    result = capture.output(pod::use(mod/nested/a/b))
    expect_equal(result, 'a/b/__init__.r')

    result = capture.output(pod::use(mod/nested/a/b/c))
    expect_equal(result, 'a/b/c/__init__.r')

    result = capture.output(pod::use(mod/nested/a/b/d))
    expect_equal(result, 'a/b/d/__init__.r')
})

test_that('module can export nested submodules', {
    pod::use(mod/b)
    expect_equal(b$answer, 42L)
})
