defmodule OTP.StackTest do
    
    use ExUnit.Case
    
    test "push and pop" do
      {:ok, pid} = Stack.start_link([])
      assert {:error, :empty} = Stack.pop(pid)
      :ok = Stack.push(pid, 1)
      assert {:ok, 1} = Stack.pop(pid)
    end

end