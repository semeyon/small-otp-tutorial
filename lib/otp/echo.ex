defmodule OTP.Echo do

    def start_link do
        pid = spawn_link(__MODULE__, :loop, [])
        {:ok, pid}
    end

    def send(pid, msg) do
        Kernel.send(pid, {msg, self()})
    end

    def async_send(pid, msg) do
        Kernel.send(pid, {msg, self()})
    end

    # @loop_timeout 10
    # @sync_send_timeout 200

    def sync_send(pid, msg) do
        async_send(pid, msg)
        receive do
            msg -> msg
        end
    end

    def loop do
        receive do
            {:no_replay, _caller} -> 
                loop()
            {msg, caller} ->
                Kernel.send(caller, msg)
                loop()
        after
            10 ->
                exit(:normal)
        end
    end

end