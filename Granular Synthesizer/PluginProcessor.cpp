#include "PluginProcessor.h"
#include "PluginEditor.h"

GranularSynthVSTAudioProcessor::GranularSynthVSTAudioProcessor()
#ifndef JucePlugin_PreferredChannelConfigurations
     : AudioProcessor (BusesProperties()
                     #if ! JucePlugin_IsMidiEffect
                      #if ! JucePlugin_IsSynth
                       .withInput  ("Input",  juce::AudioChannelSet::stereo(), true)
                      #endif
                       .withOutput ("Output", juce::AudioChannelSet::stereo(), true)
                     #endif
                       ),
#endif
       apvts(*this, nullptr, "Parameters", createParameters())
{
    // Initialize grains array
    grains.resize(maxGrains);
    for (auto& grain : grains)
        grain.active = false;
    
    // Add listeners for parameters
    apvts.addParameterListener("grainSize", this);
    apvts.addParameterListener("pitchShift", this);
    apvts.addParameterListener("randomization", this);
    apvts.addParameterListener("dryWet", this);
    apvts.addParameterListener("density", this);
    apvts.addParameterListener("timeStretch", this);
    
    // Initialize parameter values
    grainSize = apvts.getRawParameterValue("grainSize")->load();
    pitchShift = apvts.getRawParameterValue("pitchShift")->load();
    grainRandomization = apvts.getRawParameterValue("randomization")->load();
    dryWet = apvts.getRawParameterValue("dryWet")->load();
    density = apvts.getRawParameterValue("density")->load();
    timeStretch = apvts.getRawParameterValue("timeStretch")->load();
}

GranularSynthVSTAudioProcessor::~GranularSynthVSTAudioProcessor()
{
    apvts.removeParameterListener("grainSize", this);
    apvts.removeParameterListener("pitchShift", this);
    apvts.removeParameterListener("randomization", this);
    apvts.removeParameterListener("dryWet", this);
    apvts.removeParameterListener("density", this);
    apvts.removeParameterListener("timeStretch", this);
}

const juce::String GranularSynthVSTAudioProcessor::getName() const
{
    return JucePlugin_Name;
}

bool GranularSynthVSTAudioProcessor::acceptsMidi() const
{
   #if JucePlugin_WantsMidiInput
    return true;
   #else
    return false;
   #endif
}

bool GranularSynthVSTAudioProcessor::producesMidi() const
{
   #if JucePlugin_ProducesMidiOutput
    return true;
   #else
    return false;
   #endif
}

bool GranularSynthVSTAudioProcessor::isMidiEffect() const
{
   #if JucePlugin_IsMidiEffect
    return true;
   #else
    return false;
   #endif
}

double GranularSynthVSTAudioProcessor::getTailLengthSeconds() const
{
    return 0.0;
}

int GranularSynthVSTAudioProcessor::getNumPrograms()
{
    return 1;
}

int GranularSynthVSTAudioProcessor::getCurrentProgram()
{
    return 0;
}

void GranularSynthVSTAudioProcessor::setCurrentProgram (int index)
{
}

const juce::String GranularSynthVSTAudioProcessor::getProgramName (int index)
{
    return {};
}

void GranularSynthVSTAudioProcessor::changeProgramName (int index, const juce::String& newName)
{
}

void GranularSynthVSTAudioProcessor::parameterChanged(const juce::String& parameterID, float newValue)
{
    if (parameterID == "grainSize")
        grainSize = newValue;
    else if (parameterID == "pitchShift")
        pitchShift = newValue;
    else if (parameterID == "randomization")
        grainRandomization = newValue;
    else if (parameterID == "dryWet")
        dryWet = newValue;
    else if (parameterID == "density")
        density = newValue;
    else if (parameterID == "timeStretch")
        timeStretch = newValue;
}

juce::AudioProcessorValueTreeState::ParameterLayout GranularSynthVSTAudioProcessor::createParameters()
{
    std::vector<std::unique_ptr<juce::RangedAudioParameter>> params;
    
    // Grain size: 10ms to 500ms
    params.push_back(std::make_unique<juce::AudioParameterFloat>("grainSize", "Grain Size", 
                      juce::NormalisableRange<float>(0.01f, 0.5f, 0.001f, 0.5f), 0.1f,
                      juce::String(), juce::AudioProcessorParameter::genericParameter,
                      [](float value, int) { return juce::String(value * 1000.0f, 1) + " ms"; }));
    
    // Pitch shift: 0.5x to 2.0x (one octave down to one octave up)
    params.push_back(std::make_unique<juce::AudioParameterFloat>("pitchShift", "Pitch Shift", 
                      juce::NormalisableRange<float>(0.5f, 2.0f, 0.01f, 0.5f), 1.0f,
                      juce::String(), juce::AudioProcessorParameter::genericParameter,
                      [](float value, int) { 
                          if (value == 1.0f) return juce::String("Original");
                          float semitones = 12.0f * std::log2(value);
                          return juce::String(semitones, 1) + " st"; 
                      }));
    
    // Randomization: 0% to 100%
    params.push_back(std::make_unique<juce::AudioParameterFloat>("randomization", "Randomization", 
                      juce::NormalisableRange<float>(0.0f, 1.0f, 0.01f), 0.0f,
                      juce::String(), juce::AudioProcessorParameter::genericParameter,
                      [](float value, int) { return juce::String(int(value * 100)) + "%"; }));
    
    // Dry / Wet: 0% to 100%
    params.push_back(std::make_unique<juce::AudioParameterFloat>("dryWet", "Dry/Wet", 
                      juce::NormalisableRange<float>(0.0f, 1.0f, 0.01f), 1.0f,
                      juce::String(), juce::AudioProcessorParameter::genericParameter,
                      [](float value, int) { return juce::String(int(value * 100)) + "%"; }));
    
    // Density: 0% to 100%
    params.push_back(std::make_unique<juce::AudioParameterFloat>("density", "Density", 
                      juce::NormalisableRange<float>(0.1f, 1.0f, 0.01f), 0.5f,
                      juce::String(), juce::AudioProcessorParameter::genericParameter,
                      [](float value, int) { return juce::String(int(value * 100)) + "%"; }));
    
    // Time stretch: 0.5x to 2.0x (half speed to double speed)
    params.push_back(std::make_unique<juce::AudioParameterFloat>("timeStretch", "Time Stretch", 
                      juce::NormalisableRange<float>(0.5f, 2.0f, 0.01f, 0.5f), 1.0f,
                      juce::String(), juce::AudioProcessorParameter::genericParameter,
                      [](float value, int) { return juce::String(value, 2) + "x"; }));
    
    return { params.begin(), params.end() };
}

void GranularSynthVSTAudioProcessor::prepareToPlay (double sampleRate, int samplesPerBlock)
{
    // Initialize processing variables
    currentSampleRate = sampleRate;
    
    // Calculate buffer size - 2 seconds should be enough for most grain sizes
    inputBufferLength = static_cast<int>(sampleRate * 2.0);
    inputBuffer.setSize(2, inputBufferLength);
    inputBuffer.clear();
    inputBufferPos = 0;
    
    // Reset grain triggering
    samplesUntilNextGrain = 0;
    
    // Reset all grains
    for (auto& grain : grains)
        grain.active = false;
}

void GranularSynthVSTAudioProcessor::releaseResources()
{
}

#ifndef JucePlugin_PreferredChannelConfigurations
bool GranularSynthVSTAudioProcessor::isBusesLayoutSupported (const BusesLayout& layouts) const
{
  #if JucePlugin_IsMidiEffect
    juce::ignoreUnused (layouts);
    return true;
  #else
    if (layouts.getMainOutputChannelSet() != juce::AudioChannelSet::mono()
     && layouts.getMainOutputChannelSet() != juce::AudioChannelSet::stereo())
        return false;

   #if ! JucePlugin_IsSynth
    if (layouts.getMainOutputChannelSet() != layouts.getMainInputChannelSet())
        return false;
   #endif

    return true;
  #endif
}
#endif

void GranularSynthVSTAudioProcessor::processBlock (juce::AudioBuffer<float>& buffer, juce::MidiBuffer& midiMessages)
{
    juce::ScopedNoDenormals noDenormals;
    auto totalNumInputChannels  = getTotalNumInputChannels();
    auto totalNumOutputChannels = getTotalNumOutputChannels();

    // Clear any output channels that don't contain input data
    for (auto i = totalNumInputChannels; i < totalNumOutputChannels; ++i)
        buffer.clear (i, 0, buffer.getNumSamples());

    // Create a copy of the input buffer for the dry signal
    juce::AudioBuffer<float> dryBuffer;
    if (dryWet < 1.0f) {
        dryBuffer.makeCopyOf(buffer);
    }
    
    // Copy input to circular buffer
    int numSamples = buffer.getNumSamples();
    for (int channel = 0; channel < juce::jmin(2, totalNumInputChannels); ++channel) {
        for (int i = 0; i < numSamples; ++i) {
            inputBuffer.setSample(channel, (inputBufferPos + i) % inputBufferLength, 
                                  buffer.getSample(channel, i));
        }
    }
    
    // Clear output buffer for grain processing
    buffer.clear();
    
    // Calculate grain size in samples
    int grainSizeSamples = static_cast<int>(grainSize * currentSampleRate);
    
    // Calculate grain interval in samples based on density and time stretch
    int grainInterval = static_cast<int>(grainSizeSamples * (1.1f - density) / timeStretch);
    grainInterval = juce::jmax(1, grainInterval);  // Ensure at least 1 sample between grains
    
    // Process each sample
    for (int sample = 0; sample < numSamples; ++sample) {
        // Time to trigger a new grain?
        if (--samplesUntilNextGrain <= 0) {
            triggerGrain();
            samplesUntilNextGrain = grainInterval;
        }
        
        // Process active grains
        for (auto& grain : grains) {
            if (grain.active) {
                // Calculate playback position with pitch shift
                float relativePos = grain.playPosition / static_cast<float>(grain.length);
                
                // Apply window function to avoid clicks
                float windowGain = windowFunction(relativePos);
                
                // Calculate the source position in the input buffer
                float sourcePosition = grain.startPosition + (grain.playPosition * grain.pitch);
                
                // Ensure within buffer bounds
                while (sourcePosition >= inputBufferLength)
                    sourcePosition -= inputBufferLength;
                while (sourcePosition < 0)
                    sourcePosition += inputBufferLength;
                
                // Get interpolated sample for each channel
                for (int channel = 0; channel < juce::jmin(2, totalNumOutputChannels); ++channel) {
                    // Apply panning
                    float panGain = (channel == 0) ? (1.0f - grain.pan) : grain.pan;
                    
                    // Get the sample and add it to the output
                    float sampleValue = getInterpolatedSample(inputBuffer, channel, sourcePosition);
                    buffer.addSample(channel, sample, sampleValue * grain.level * windowGain * panGain * 0.5f);
                }
                
                // Move grain playback position forward
                grain.playPosition += 1.0f;
                
                // Deactivate grain if it has reached its end
                if (grain.playPosition >= grain.length)
                    grain.active = false;
            }
        }
        
        // Move the input buffer position forward
        inputBufferPos = (inputBufferPos + 1) % inputBufferLength;
    }
    
    // Apply dry/wet mix
    if (dryWet < 1.0f) {
        for (int channel = 0; channel < juce::jmin(2, totalNumOutputChannels); ++channel) {
            buffer.applyGain(channel, 0, numSamples, dryWet);
            for (int i = 0; i < numSamples; ++i) {
                buffer.addSample(channel, i, dryBuffer.getSample(channel, i) * (1.0f - dryWet));
            }
        }
    }
}

void GranularSynthVSTAudioProcessor::triggerGrain()
{
    // Calculate grain size in samples
    int grainSizeSamples = static_cast<int>(grainSize * currentSampleRate);
    
    // Find the next available grain
    Grain& grain = grains[nextGrainIndex];
    nextGrainIndex = (nextGrainIndex + 1) % maxGrains;
    
    // Set grain parameters
    grain.active = true;
    grain.length = grainSizeSamples;
    grain.playPosition = 0.0f;
    
    // Apply randomization to the start position if needed
    int randomOffset = 0;
    if (grainRandomization > 0.0f) {
        int maxOffset = static_cast<int>(grainRandomization * currentSampleRate); // max 1 second offset
        randomOffset = random.nextInt(maxOffset * 2 + 1) - maxOffset;
    }
    
    // Starting position is the current input buffer position with randomization
    grain.startPosition = (inputBufferPos - grainSizeSamples + randomOffset + inputBufferLength) % inputBufferLength;
    
    // Set the pitch shift
    grain.pitch = pitchShift;
    
    // Set the grain level - could be randomized for more variation
    grain.level = 1.0f;
    
    // Set random pan position between 0.3 and 0.7 (subtle stereo spread)
    grain.pan = randomFloat(0.3f, 0.7f);
}

float GranularSynthVSTAudioProcessor::getInterpolatedSample(juce::AudioSampleBuffer& buffer, int channel, float position)
{
    // Linear interpolation between samples
    int pos1 = static_cast<int>(position) % inputBufferLength;
    int pos2 = (pos1 + 1) % inputBufferLength;
    float fraction = position - static_cast<float>(static_cast<int>(position));
    
    float sample1 = buffer.getSample(channel, pos1);
    float sample2 = buffer.getSample(channel, pos2);
    
    return sample1 + fraction * (sample2 - sample1);
}

float GranularSynthVSTAudioProcessor::randomFloat(float min, float max)
{
    return min + (max - min) * random.nextFloat();
}

float GranularSynthVSTAudioProcessor::windowFunction(float position)
{
    // Hann window
    return 0.5f * (1.0f - std::cos(2.0f * juce::MathConstants<float>::pi * position));
}

bool GranularSynthVSTAudioProcessor::hasEditor() const
{
    return true;
}

juce::AudioProcessorEditor* GranularSynthVSTAudioProcessor::createEditor()
{
    return new GranularSynthVSTAudioProcessorEditor (*this);
}

void GranularSynthVSTAudioProcessor::getStateInformation (juce::MemoryBlock& destData)
{
    // Store parameter state in XML format
    auto state = apvts.copyState();
    std::unique_ptr<juce::XmlElement> xml(state.createXml());
    copyXmlToBinary(*xml, destData);
}

void GranularSynthVSTAudioProcessor::setStateInformation (const void* data, int sizeInBytes)
{
    // Restore parameter state from XML
    std::unique_ptr<juce::XmlElement> xmlState(getXmlFromBinary(data, sizeInBytes));
    
    if (xmlState.get() != nullptr && xmlState->hasTagName(apvts.state.getType()))
        apvts.replaceState(juce::ValueTree::fromXml(*xmlState));
}

juce::AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
    return new GranularSynthVSTAudioProcessor();
}