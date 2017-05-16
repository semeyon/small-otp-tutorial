defmodule OTP.Echo do

    def start_link do
        pid = spawn_link(__MODULE__, :loop, [])
        {:ok, pid}
    end

    def async_send(pid, msg) do
        ref = make_ref()
        Kernel.send(pid, {ref, self(), msg})
        ref
    end

    @loop_timeout 10
    @sync_send_timeout 200

    def sync_send(pid, msg) do
        ref = async_send(pid, msg)
        receive do
            {^ref, msg} -> msg
        after
            @sync_send_timeout -> {:error, :timeout}
        end
    end

    def loop do
        receive do
            {_ref, _caller, :no_reply} ->
                loop()
            {ref, caller, :long_computation} ->
                Process.sleep (@sync_send_timeout + 1)
                Kernel.send(caller, {ref, :long_computation})
            {ref, caller, msg} ->
                Kernel.send(caller, {ref, msg})
                loop()
            after
                @loop_timeout -> :normal
        end
    end

end