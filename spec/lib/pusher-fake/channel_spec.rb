require "spec_helper"

describe PusherFake::Channel, ".factory" do
  shared_examples_for "a channel factory" do
    subject { described_class }

    let(:channel) { double }

    before do
      allow(channel_class).to receive(:new).and_return(channel)
    end

    after do
      subject.reset
    end

    it "caches the channel" do
      allow(channel_class).to receive(:new).and_call_original

      factory_one = subject.factory(name)
      factory_two = subject.factory(name)

      expect(factory_one).to eq(factory_two)
    end

    it "creates the channel by name" do
      subject.factory(name)

      expect(channel_class).to have_received(:new).with(name)
    end

    it "returns the channel instance" do
      factory = subject.factory(name)

      expect(factory).to eq(channel)
    end
  end

  context "for a public channel" do
    let(:name)          { "channel" }
    let(:channel_class) { PusherFake::Channel::Public }

    it_behaves_like "a channel factory"
  end

  context "for a private channel" do
    let(:name)          { "private-channel" }
    let(:channel_class) { PusherFake::Channel::Private }

    it_behaves_like "a channel factory"
  end

  context "for a presence channel" do
    let(:name)          { "presence-channel" }
    let(:channel_class) { PusherFake::Channel::Presence }

    it_behaves_like "a channel factory"
  end
end

describe PusherFake::Channel, ".remove" do
  subject { described_class }

  let(:channels)   { { channel_1: channel_1, channel_2: channel_2 } }
  let(:connection) { double }

  let(:channel_1) do
    instance_double(PusherFake::Channel::Public,
                    remove:      nil,
                    connections: instance_double(Array, empty?: true))
  end

  let(:channel_2) do
    instance_double(PusherFake::Channel::Public,
                    remove:      nil,
                    connections: instance_double(Array, empty?: false))
  end

  before do
    allow(subject).to receive(:channels).and_return(channels)
  end

  it "removes the connection from all channels" do
    subject.remove(connection)

    expect(channel_1).to have_received(:remove).with(connection)
    expect(channel_2).to have_received(:remove).with(connection)
  end

  it "deletes a channel with no connections remaining" do
    subject.remove(connection)

    expect(channels).not_to have_key(:channel_1)
  end

  it "does not delete a channel with connections remaining" do
    subject.remove(connection)

    expect(channels).to have_key(:channel_2)
  end

  it "handles channels not being defined" do
    allow(subject).to receive(:channels).and_return(nil)

    expect do
      subject.remove(connection)
    end.not_to raise_error
  end
end

describe PusherFake::Channel, ".reset" do
  subject { described_class }

  it "empties the channel cache" do
    subject.factory("example")
    subject.reset

    expect(subject.channels).to eq({})
  end
end
