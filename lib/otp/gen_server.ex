defmodule OTP.GenServer do


    defmacro __using__(_opts) do
        quote do
            @behaviour OTP.GenServer
        end
    end

    def start_link(mod, loopdata, opts \\ []) do
        case Map.get(opts, :name) do
            nil ->
                pid = spawn_link(__MODULE__, :loop, [mod, loopdata])
                {:ok, pid}
            name when is_atom(name) ->
                pid = spawn_link(__MODULE__, :loop, [mod, loopdata])
                Process.register(pid, name)
                {:ok, pid}
            _invalid_name ->
                {:error, :invalid_name}
        end
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