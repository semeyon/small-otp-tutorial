defmodule OTP.Supervisor do

    def start(name) do
      pid = spawn(__MODULE__, :init, [])
      Process.register(pid, name)
      {:ok, pid}
    end

    def init() do
        Process.flag(:trap_exit, true)
        loop([])
    end

    defp loop(children) do
        receive do
            {:start_child, callerpid, mod, func, args} ->
                pid = spawn_link(mod, func, args)
                send(callerpid, {:ok, pid})
                loop([{pid, mod, func, args}|children])
            {:EXIT, pid, _reason} ->
                newchildren = List.keydelete(children, pid, 0)
                child = List.keyfind(children, pid, 0)
                {_, mod, func, args} = child
                    newpid = spawn_link(mod, func, args)
                    loop([{newpid, mod, func, args}|newchildren])
            :stop ->
                kill_children(children)
        end
    end

    defp kill_children(children) do
        killer = fn ({pid, _mod, _func, _args}) ->
            Process.exit(pid, :kill)
        end
        Enum.each(children, killer)
    end

end