defmodule SimpleNeuron do

  def create do
    weights = [
      :rand.uniform()-0.5,
      :rand.uniform()-0.5,
      :rand.uniform()-0.5
    ]
    Process.register(spawn(__MODULE__, :loop, [weights]), :neuron)
  end


  def loop(weights) do
    receive do
      {from, input} ->
        IO.puts("Processing\n Input: #{inspect(input)}\n Using weights: #{inspect(weights)}")
        dot_product = dot(input, weights, 0)
        output = [ :math.tanh(dot_product) ]
        send(from, {:result, output})
        loop(weights)
    end
  end

  def sense(signal) do
    case is_list(signal) && length(signal) == 2 do
      true ->
        send(:neuron, {self(), signal})
        receive do
          {:result, output} ->
            IO.puts(" Output: #{inspect(output)}")
        end
      false ->
          IO.puts("The Signal must be a list of length 2~n")
    end
  end


  defp dot([i | input], [w | weights], acc) do
    dot(input, weights, i*w + acc)
  end
  defp dot([], [bias], acc) do
    bias + acc
  end

end