require 'spec_helper'

describe Pocketsphinx::Decoder do
  subject { Pocketsphinx::Decoder.new(configuration) }
  let(:ps_api) { subject.ps_api }
  let(:ps_decoder) { double }
  let(:configuration) { Pocketsphinx::Configuration.default }

  before do
    subject.ps_api = double
    allow(ps_api).to receive(:ps_init).and_return(ps_decoder)
  end

  describe '#reconfigure' do
    it 'calls libpocketsphinx and the configuration post initialize hook' do
      expect(ps_api)
        .to receive(:ps_reinit)
        .with(subject.ps_decoder, configuration.ps_config)
        .and_return(0)

      configuration.define_singleton_method(:post_init_decoder) { |decoder| }

      expect(configuration)
        .to receive(:post_init_decoder)
        .with(subject)

      subject.reconfigure
    end

    it 'sets a new configuration if one is passed' do
      new_config = Struct.new(:ps_config).new(:ps_config)

      expect(ps_api)
        .to receive(:ps_reinit)
        .with(subject.ps_decoder, new_config.ps_config)
        .and_return(0)

      subject.reconfigure(new_config)

      expect(subject.configuration).to be(new_config)
    end

    it 'raises an exception on error' do
      expect(ps_api)
        .to receive(:ps_reinit)
        .with(subject.ps_decoder, configuration.ps_config)
        .and_return(-1)

      expect { subject.reconfigure }
        .to raise_exception "Decoder#reconfigure failed with error code -1"
    end
  end

  describe '#process_raw' do
    it 'calls libpocketsphinx' do
      FFI::MemoryPointer.new(:int16, 4096) do |buffer|
        expect(ps_api)
          .to receive(:ps_process_raw)
          .with(subject.ps_decoder, buffer, 4096, 0, 0)
          .and_return(0)

        subject.process_raw(buffer, 4096, false, false)
      end
    end

    it 'raises an exception on error' do
      FFI::MemoryPointer.new(:int16, 4096) do |buffer|
        expect(ps_api)
          .to receive(:ps_process_raw)
          .with(subject.ps_decoder, buffer, 4096, 0, 0)
          .and_return(-1)

        expect { subject.process_raw(buffer, 4096, false, false) }
          .to raise_exception "Decoder#process_raw failed with error code -1"
      end
    end
  end

  describe '#start_utterance' do
    it 'calls libpocketsphinx' do
      expect(ps_api)
        .to receive(:ps_start_utt)
        .with(subject.ps_decoder)
        .and_return(0)

      subject.start_utterance
    end

    it 'raises an exception on error' do
      expect(ps_api)
        .to receive(:ps_start_utt)
        .with(subject.ps_decoder)
        .and_return(-1)

      expect { subject.start_utterance }
        .to raise_exception "Decoder#start_utterance failed with error code -1"
    end
  end

  describe '#end_utterance' do
    it 'calls libpocketsphinx' do
      expect(ps_api)
        .to receive(:ps_end_utt)
        .with(subject.ps_decoder)
        .and_return(0)

      subject.end_utterance
    end

    it 'raises an exception on error' do
      expect(ps_api)
        .to receive(:ps_end_utt)
        .with(subject.ps_decoder)
        .and_return(-1)

      expect { subject.end_utterance }
        .to raise_exception "Decoder#end_utterance failed with error code -1"
    end
  end

  describe '#in_speech' do
    it 'calls libpocketsphinx' do
      expect(ps_api)
        .to receive(:ps_get_in_speech)
        .with(subject.ps_decoder)
        .and_return(0)

      expect(subject.in_speech?).to eq(false)
    end
  end

  describe '#hypothesis' do
    it 'calls libpocketsphinx' do
      expect(ps_api)
        .to receive(:ps_get_hyp) do |ps_decoder, mp_path_score|
          expect(ps_decoder).to eq(subject.ps_decoder)
          expect(mp_path_score).to be_a(FFI::MemoryPointer)

          mp_path_score.put_int32(0, 20)

          "Hypothesis"
        end

      hypothesis = subject.hypothesis

      expect(hypothesis).to eq("Hypothesis")
      expect(hypothesis.path_score).to eq(20)
    end
  end

  describe '#words' do
    let(:iterator) { FFI::MemoryPointer.from_string("") }

    it 'calls libpocketsphinx' do
      expect(ps_api).to receive(:ps_seg_iter).ordered.and_return(iterator)

      expect(ps_api).to receive(:ps_seg_frames).ordered do |seg_iter, start_frame, end_frame|
        start_frame.put_int16(0, 10)
        end_frame.put_int16(0, 20)
      end

      expect(ps_api).to receive(:ps_seg_word).ordered.and_return("one")
      expect(ps_api).to receive(:ps_seg_next).ordered.and_return(iterator)

      expect(ps_api).to receive(:ps_seg_frames).ordered do |seg_iter, start_frame, end_frame|
        start_frame.put_int16(0, 30)
        end_frame.put_int16(0, 40)
      end

      expect(ps_api).to receive(:ps_seg_word).ordered.and_return("two")
      expect(ps_api).to receive(:ps_seg_next).ordered.and_return(FFI::Pointer::NULL)

      words = subject.words

      expect(words[0]).to eq(Pocketsphinx::Decoder::Word.new("one", 10, 20))
      expect(words[1]).to eq(Pocketsphinx::Decoder::Word.new("two", 30, 40))
    end
  end

  describe '#set_jsgf_string' do
    it 'calls libpocketsphinx' do
      expect(ps_api)
        .to receive(:ps_set_jsgf_string)
        .with(subject.ps_decoder, 'default', 'JSGF')
        .and_return(0)

      subject.set_jsgf_string('JSGF')
    end

    it 'raises an exception on error' do
      expect(ps_api)
        .to receive(:ps_set_jsgf_string)
        .and_return(-1)

      expect { subject.set_jsgf_string('JSGF') }
        .to raise_exception "Decoder#set_jsgf_string failed with error code -1"
    end
  end

  describe '#set_search' do
    it 'calls libpocketsphinx' do
      expect(ps_api)
        .to receive(:ps_set_search)
        .with(subject.ps_decoder, 'search')
        .and_return(0)

      subject.set_search('search')
    end

    it 'raises an exception on error' do
      expect(ps_api)
        .to receive(:ps_set_search)
        .and_return(-1)

      expect { subject.set_search('search') }
        .to raise_exception "Decoder#set_search failed with error code -1"
    end
  end

  describe '#unset_search' do
    it 'calls libpocketsphinx' do
      expect(ps_api)
        .to receive(:ps_unset_search)
        .with(subject.ps_decoder, 'search')
        .and_return(0)

      subject.unset_search('search')
    end

    it 'raises an exception on error' do
      expect(ps_api)
        .to receive(:ps_unset_search)
        .and_return(-1)

      expect { subject.unset_search('search') }
        .to raise_exception "Decoder#unset_search failed with error code -1"
    end
  end

  describe '#get_search' do
    it 'calls libpocketsphinx' do
      expect(ps_api)
        .to receive(:ps_get_search)
        .and_return(:search)

      expect(subject.get_search).to eq(:search)
    end
  end
end
