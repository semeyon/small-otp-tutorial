defmodule Stack do

    alias OTP.GenServer
    # use GenServer

    ## PUBLIC

    def start_link(initial) do
        GenServer.start_link(__MODULE__, initial)
    end

    def push(pid, element) do
        GenServer.cast(pid, {:push, element})
    end

    def pop(pid) do
        GenServer.call(pid, :pop)
    end

    ## CALLBACKS

    def  handle_call(:pop, _from, []) do
      {:reply, {:error, :empty}, []}
    end

    def handle_call(:pop, _from, [h | t]) do
      {:reply, {:ok, h}, t}
    end

    def handle_cast({:push, el}, state) do
      {:noreply, [el | state]}
    end

end