defmodule OTP.EchoTest do
    use ExUnit.Case
    import Logger
    alias OTP.Echo

    # test "echo" do
    #     {:ok, pid} = Echo.start_link()
    #     Echo.send(pid, :hello)
    #     assert_receive :hello
    #     Echo.send(pid, :hi)
    #     assert_receive :hi
    # end

    test "timeout" do
        {:ok, pid} = Echo.start_link()
        Process.sleep(50)
        assert false == Process.alive?(pid)
    end

    test "async echo" do
        {:ok, pid} = Echo.start_link()
        Echo.async_send(pid, :hello)
        assert_receive :hello
        Echo.async_send(pid, :hi)
        assert_receive :hi
    end

    test "sync echo" do
        {:ok, pid} = Echo.start_link()
        assert :hello == Echo.sync_send(pid, :hello)
    end

    # test "sync send timout" do
    #     {:ok, pid} = Echo.start_link()
    #     assert {:error, :timeout} == Echo.sync_send(pid, :no_reply)
    # end

end