require 'rspec/core/formatters/documentation_formatter'
require 'colorize'

# custom rspec output formatter
class CustomFormatter < RSpec::Core::Formatters::DocumentationFormatter
  RSpec::Core::Formatters.register self, :example_group_started, :example_group_finished,
                                   :example_passed, :example_pending, :example_failed

  def initialize(output)
    super
    @group_level = 0
  end

  def example_group_started(notification)
    output.puts if @group_level.zero?
    output.puts "#{current_indentation}Running: #{notification.group.file_path.strip}".colorize(:light_blue)

    @group_level += 1
  end

  def example_group_finished(_notification)
    @group_level -= 1 if @group_level.positive?
  end

  def example_passed(passed)
    output_description(passed)
    output.puts passed_output(passed.example)
    bdd_puts(passed.example)
  end

  def example_pending(pending)
    output_description(pending)
    output.puts pending_output(pending.example,
                               pending.example.execution_result.pending_message)
    bdd_puts(pending.example)
  end

  def example_failed(failure)
    output_description(failure)
    output.puts failure_output(failure.example)
    bdd_puts(failure.example)
    additional_info_output
  end

  private

  def additional_info_output
    url = CustomFormatter.instance_variable_get(:@url)
    output.puts "URL of Failure: #{url}\n".colorize(:light_blue)
  end

  def bdd_puts(example)
    bdd_container = Bdd.get_container(example)
    next_indentation = '  ' * (@group_level + 1)
    output.puts bdd_container.map { |message| "#{next_indentation}#{message}" }
    bdd_container.clear
  end

  def output_description(example)
    output.puts if @group_level.zero?
    description = example.example.metadata[:example_group][:description]
    output.puts "#{description.strip}"
    @group_level -= 1 if @group_level.positive?
  end

  def passed_output(example)
    RSpec::Core::Formatters::ConsoleCodes.wrap("#{current_indentation}#{example.description.strip}", :success)
  end

  def pending_output(example, message)
    RSpec::Core::Formatters::ConsoleCodes.wrap("#{current_indentation}#{example.description.strip} " \
                      "(PENDING: #{message})",
                                               :pending)
  end

  def failure_output(example)
    RSpec::Core::Formatters::ConsoleCodes.wrap("#{current_indentation}#{example.description.strip} " \
                      "(FAILED - #{next_failure_index}) ",
                                               :failure)
  end

  def next_failure_index
    @next_failure_index ||= 0
    @next_failure_index += 1
  end

  def current_indentation
    '  ' * @group_level
  end
end