# typed: false
require 'spec_helper'
require 'ddtrace'
require 'ddtrace/runtime/metrics'

RSpec.describe Datadog::Runtime::Metrics do
  describe '::associate_trace' do
    subject(:associate_trace) { described_class.associate_trace(trace) }

    context 'when given nil' do
      let(:trace) { nil }

      it 'does nothing' do
        expect(Datadog.runtime_metrics).to_not receive(:register_service)
        associate_trace
      end
    end

    context 'when given a trace' do
      let(:trace) { Datadog::TraceSegment.new(spans, service: service) }

      context 'with a service but no spans' do
        let(:spans) { [] }
        let(:service) { nil }

        it 'does not register the trace\'s service' do
          expect(Datadog.runtime_metrics).to_not receive(:register_service)
          associate_trace
        end
      end

      context 'without a service but with spans' do
        let(:spans) { Array.new(2) { Datadog::Span.new('my.task', service: 'parser') } }
        let(:service) { nil }

        it 'does not register the trace\'s service' do
          expect(Datadog.runtime_metrics).to_not receive(:register_service)
          associate_trace
        end
      end

      context 'with a service and spans' do
        let(:spans) { Array.new(2) { Datadog::Span.new('my.task', service: service) } }
        let(:service) { 'parser' }

        it 'registers the trace\'s service' do
          expect(Datadog.runtime_metrics).to receive(:register_service).with(service)
          associate_trace
        end
      end
    end
  end
end
