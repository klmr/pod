context('hooks')

test_that('on_load hook is invoked', {
    pod::use(mod/hooks/a)
    expect_equal(a$on_load_called, 1L)
})

test_that('on_load hook is invoked only once', {
    local({
        pod::use(mod/hooks/a)
        expect_equal(a$on_load_called, 1L) # Still 1
    })
    local({
        pod::use(mod/hooks/a)
        expect_equal(a$on_load_called, 1L) # STILL 1
    })
})

test_that('on_unload hook is invoked during unloading', {
    unload_called = 0L

    pod::use(mod/hooks/a)
    a$register_unload_callback(function () unload_called <<- unload_called + 1L)

    expect_equal(unload_called, 0L)
    pod::unload(a)
    expect_equal(unload_called, 1L)
})

test_that('hooks are invoked during reloading', {
    unload_called = 0L

    pod::use(mod/hooks/a)
    a$register_unload_callback(function () unload_called <<- unload_called + 1L)

    expect_equal(unload_called, 0L)
    pod::reload(a)
    expect_equal(unload_called, 1L)
    expect_equal(a$on_load_called, 1L)
})
