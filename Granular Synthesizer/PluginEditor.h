#pragma once

#include <JuceHeader.h>
#include "PluginProcessor.h"

class GranularSynthVSTAudioProcessorEditor  : public juce::AudioProcessorEditor
{
public:
    GranularSynthVSTAudioProcessorEditor (GranularSynthVSTAudioProcessor&);
    ~GranularSynthVSTAudioProcessorEditor() override;

    void paint (juce::Graphics&) override;
    void resized() override;

private:
    // Access the processor object that created it.
    GranularSynthVSTAudioProcessor& audioProcessor;
    
    // UI Components
    juce::Slider grainSizeSlider;
    juce::Slider pitchShiftSlider;
    juce::Slider randomizationSlider;
    juce::Slider dryWetSlider;
    juce::Slider densitySlider;
    juce::Slider timeStretchSlider;
    
    juce::Label grainSizeLabel;
    juce::Label pitchShiftLabel;
    juce::Label randomizationLabel;
    juce::Label dryWetLabel;
    juce::Label densityLabel;
    juce::Label timeStretchLabel;
    
    // Parameter attachments
    std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> grainSizeAttachment;
    std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> pitchShiftAttachment;
    std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> randomizationAttachment;
    std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> dryWetAttachment;
    std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> densityAttachment;
    std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> timeStretchAttachment;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (GranularSynthVSTAudioProcessorEditor)
};