defmodule SimplestNN do

  def create do
    weights = [
      :rand.uniform()-0.5,
      :rand.uniform()-0.5,
      :rand.uniform()-0.5
    ]
    n_pid = spawn(__MODULE__, :neuron, [weights, nil, nil])
    s_pid = spawn(__MODULE__, :sensor, [n_pid])
    a_pid = spawn(__MODULE__, :actuator, [n_pid])
    send(n_pid, {:init, s_pid, a_pid})
    Process.register(spawn(__MODULE__, :cortex, [s_pid, n_pid, a_pid]), :cortex)
  end


  def neuron(weights, s_pid, a_pid) do
    receive do
      {s_pid, :forward, input} ->
        IO.puts("Processing\n Input: #{inspect(input)}\n Using weights: #{inspect(weights)}")
        dot_product = dot(input, weights, 0)
        output = [ :math.tanh(dot_product) ]
        send( a_pid, {self(), :forward, output} )
        neuron( weights, s_pid, a_pid )

      {:init, new_spid, new_apid} ->
        neuron(weights, new_spid, new_apid)

      :terminate ->
        :ok
    end
  end


  def sensor(n_pid) do
    receive do
      :sync ->
        sensory_signal = [ :rand.uniform(), :rand.uniform()]
        IO.puts("Sensing\nSignal from the env: #{inspect(sensory_signal)}")
        send(n_pid, {self(), :forward, sensory_signal})
        sensor(n_pid)

      :terminate ->
        :ok
    end
  end


  def actuator(n_pid) do
    receive do
      {n_pid, :forward, control_signal} ->
        print_screen(control_signal)
        actuator(n_pid)
      :terminate ->
        :ok
    end

  end


  def cortex(sensor_pid, neuron_pid, actuator_pid) do
    receive do
      :sense_think_act ->
        send(sensor_pid, :sync)
        cortex(sensor_pid, neuron_pid, actuator_pid)
      :terminate ->
        send(sensor_pid, :terminate)
        send(neuron_pid, :terminate)
        send(actuator_pid, :terminate)
        :ok
    end
  end



  # privfuncts

  defp print_screen(control_signal) do
    IO.puts("Acting\nUsing: #{inspect(control_signal)} to act on environment")
  end

  defp dot([],[],acc) do
    acc
  end
  defp dot([], [bias], acc) do
    bias + acc
  end
  defp dot([i | input], [w | weights], acc) do
    dot(input, weights, i*w + acc)
  end




end