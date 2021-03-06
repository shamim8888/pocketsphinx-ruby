# Changelog

**v0.2.0 - 03/03/15**

* Updated to latest Pocketsphinx API interface


**v0.1.1 - 29/10/14**

* Allow logging to be disabled
* Recognizer can now be paused (during TTS reply for example)
* Spot keywords immediately by not using speech -> silence transitions
* Return path_score and utterance_id with hypothesis
* Fix namespacing bug in Configuration::Grammar
* Improve test coverage


**v0.1.0 - 24/10/14**

* Support for JSGF grammars + very simple sentences DSL


**v0.0.3 - 21/10/14**

* Support for keyword spotting configuration
* Support reconfiguring of Decoder / Recognizer
* Fix CPU usage bug in `Microphone#read_audio_delay`
* Fix bug in `Configuration` float value type checking


**v0.0.2 - 20/10/14**

* Support for decoding raw audio files as well as live audio


**v0.0.1**

Initial release
