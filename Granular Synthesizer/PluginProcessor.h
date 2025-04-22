#pragma once

#include <JuceHeader.h>

class GranularSynthVSTAudioProcessor  : public juce::AudioProcessor,
                                        public juce::AudioProcessorValueTreeState::Listener
{
public:
    GranularSynthVSTAudioProcessor();
    ~GranularSynthVSTAudioProcessor() override;

    void prepareToPlay (double sampleRate, int samplesPerBlock) override;
    void releaseResources() override;

   #ifndef JucePlugin_PreferredChannelConfigurations
    bool isBusesLayoutSupported (const BusesLayout& layouts) const override;
   #endif

    void processBlock (juce::AudioBuffer<float>&, juce::MidiBuffer&) override;
    juce::AudioProcessorEditor* createEditor() override;
    bool hasEditor() const override;
    const juce::String getName() const override;
    bool acceptsMidi() const override;
    bool producesMidi() const override;
    bool isMidiEffect() const override;
    double getTailLengthSeconds() const override;
    int getNumPrograms() override;
    int getCurrentProgram() override;
    void setCurrentProgram (int index) override;
    const juce::String getProgramName (int index) override;
    void changeProgramName (int index, const juce::String& newName) override;
    void getStateInformation (juce::MemoryBlock& destData) override;
    void setStateInformation (const void* data, int sizeInBytes) override;
    
    // Parameter state
    juce::AudioProcessorValueTreeState apvts;
    
    // Parameter listener callback
    void parameterChanged(const juce::String& parameterID, float newValue) override;

private:
    // Granular synthesis parameters
    float grainSize = 0.1f;           // Grain size in seconds
    float pitchShift = 1.0f;          // Pitch shift factor (1.0 = original)
    float grainRandomization = 0.0f;  // Amount of randomization for grain positions (0.0 - 1.0)
    float dryWet = 1.0f;              // Dry/Wet mix (0.0 = dry, 1.0 = wet)
    float density = 0.5f;             // Grain density / overlap
    float timeStretch = 1.0f;         // Time stretch factor (0.5 = half speed, 2.0 = double speed)
    
    // Audio buffers
    juce::AudioSampleBuffer inputBuffer;
    int inputBufferPos = 0;
    int inputBufferLength = 0;
    
    // Grain management
    struct Grain
    {
        int startPosition = 0;
        int length = 0;
        float pitch = 1.0f;
        float level = 1.0f;
        float playPosition = 0.0f;
        bool active = false;
        float pan = 0.5f;
    };
    
    std::vector<Grain> grains;
    int maxGrains = 64;
    int nextGrainIndex = 0;
    int samplesUntilNextGrain = 0;
    
    // Utility methods
    juce::AudioProcessorValueTreeState::ParameterLayout createParameters();
    void triggerGrain();
    float getInterpolatedSample(juce::AudioSampleBuffer& buffer, int channel, float position);
    float randomFloat(float min, float max);
    float windowFunction(float position); // Position between 0 and 1
    
    // Random number generator
    juce::Random random;
    
    // Current sample rate and other processing variables
    double currentSampleRate = 44100.0;
    
    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (GranularSynthVSTAudioProcessor)
};