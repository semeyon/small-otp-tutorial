defmodule OTP.EchoTest do
    use ExUnit.Case
    alias OTP.Echo

    test "timeout" do
        {:ok, pid} = Echo.start_link()
        Process.sleep(50)
        assert false == Process.alive?(pid)
    end

    test "async echo" do
        {:ok, pid} = Echo.start_link()
        Echo.async_send(pid, :hello)
        assert_receive {_, :hello}
        Echo.async_send(pid, :hi)
        assert_receive {_, :hi}
    end

    test "sync echo" do
        {:ok, pid} = Echo.start_link()
        assert :hello == Echo.sync_send(pid, :hello)
    end

    test "sync send timeout" do
        {:ok, pid} = Echo.start_link()
        assert {:error, :timeout} == Echo.sync_send(pid, :no_reply)
    end

    test "sync send timeout race condition" do
        {:ok, pid} = Echo.start_link()
        Kernel.send(self(), :long_computation)
        assert {:error, :timeout} == Echo.sync_send(pid, :no_reply)
    end

end