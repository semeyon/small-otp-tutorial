defmodule OTP.GenServer do

    def start_link(mod, loopdata) do
        pid = spawn_link(__MODULE__, :loop, [mod, loopdata])
        {:ok, pid}
    end

    def cast(server, msg) do
        payload = {:"$cast", msg}
        Kernel.send(server, payload)
        :ok
    end

    def call(server, msg) do
        ref = make_ref()
        payload = {:"$call", {ref, self()}, msg}
        Kernel.send(server, payload)
        receive do
            {^ref, result} -> result
        after
            5000 -> {:error, :timeout}
        end
    end

    def loop(mod, loopdata) do
        receive do
            {:"$call", from = {ref, caller}, msg} ->
                {:reply, response, newloopdata} = mod.handle_call(msg, from, loopdata)
                Kernel.send(caller, {ref, response})
                loop(mod, newloopdata)
            {:"$cast", msg} ->
                {:noreply, newloopdata} = mod.handle_cast(msg, loopdata)
                loop(mod, newloopdata)
            _other ->
                loop(mod, loopdata)
        end
    end

    @type from :: {reference, pid}
    @callback handle_call(term, from, term)
        :: {:reply, term, term}
    @callback handle_cast(term, term)
        :: {:noreply, term}
end