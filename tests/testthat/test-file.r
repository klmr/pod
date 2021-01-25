context('file paths')

test_that('pod::file works in global namespace', {
    expect_equal(pod::file(), getwd())
    this_file = (function() getSrcFilename(sys.call(sys.nframe())))()
    expect_true(nzchar(this_file)) # Just to make sure.
    expect_true(nzchar(pod::file(this_file)))
})

test_that('pod::file works for module', {
    pod::use(mod/a)
    expect_true(grepl('/b$', pod::file('b', module = a)))
    expect_true(grepl('/c\\.r$', pod::file('c.r', module = a)))
    expect_equal(length(pod::file(c('b', 'c.r'), module = a)), 2L)
})

test_that('pod::base_path works', {
    # On earlier versions of “devtools”, this test reproducibly segfaulted due
    # to the call to `load_all` from within a script. This seems to be fixed now
    # with version 1.9.1.9000.
    script_path = 'mod/devtools_segfault.r'

    rcmd_result = rcmd(script_path)
    expect_paths_equal(rcmd_result, file.path(getwd(), 'mod'))

    rscript_result = rscript(script_path)
    expect_paths_equal(rscript_result, file.path(getwd(), 'mod'))
})

test_that('pod::file works after attaching modules', {
    # R CMD CHECK resets the working directory AFTER executing the test helpers.
    # This throws off the subsequent tests, so we need to re-set the path here
    # although this shouldn’t be necessary.
    old_opts = options(pod.path = getwd())
    on.exit(options(old_opts))

    # Test that #66 is fixed and that there are no regressions.

    expected_module_file = pod::file()
    pod::use(mod/a[...])
    expect_paths_equal(pod::file(), expected_module_file)

    modfile = in_globalenv({
        expected_module_file = pod::file()
        pod::use(a = mod/a[...])
        on.exit(pod::unload(a))
        list(actual = pod::file(), expected = expected_module_file)
    })

    expect_paths_equal(modfile$actual, modfile$expected)

    pod::use(x = mod/mod_file)
    expected_module_file = file.path(getwd(), 'mod')
    expect_paths_equal(x$this_module_file, expected_module_file)
    expect_paths_equal(x$function_module_file(), expected_module_file)
    expect_paths_equal(x$this_module_file2, expected_module_file)
    expect_paths_equal(x$after_module_attach(), expected_module_file)
    expect_paths_equal(x$after_package_attach(), expected_module_file)
    expect_paths_equal(x$nested_module_file(), expected_module_file)
})

test_that('regression #76 is fixed', {
    pod::use(x = mod/issue76)
    expect_equal(x$helper_var, 3L)
})

test_that('regression #79 is fixed', {
    script_path = 'mod/issue79.r'
    result = tail(interactive_r(script_path), 3L)

    expect_equal(result[1L], '> before; after')
    expect_equal(result[2L], 'NULL')
    # The following assertion in particular should not fail.
    expect_equal(result[3L], 'NULL')
})

test_that('common split_path operations are working', {
    expect_correct_path_split('foo')
    expect_correct_path_split('foo/')
    expect_correct_path_split('./foo')
    expect_correct_path_split('./foo/')
    expect_correct_path_split('foo/bar')
    expect_correct_path_split('foo/bar/')
    expect_is_cwd('.')
    expect_is_cwd('./')
    expect_is_cwd('./.')
    expect_correct_path_split('~')
    expect_correct_path_split('~/foo')
})

test_that('split_path is working on Unix', {
    skip_on_os('windows')

    expect_correct_path_split('/foo/bar')
    expect_correct_path_split('/foo/bar/')
    expect_correct_path_split('/.')
})

test_that('split_path is working on Windows', {
    if (.Platform$OS.type != 'windows') skip('Only run on Windows')

    # Standard paths
    # UNC paths
})
