#include "PluginProcessor.h"
#include "PluginEditor.h"

GranularSynthVSTAudioProcessorEditor::GranularSynthVSTAudioProcessorEditor (GranularSynthVSTAudioProcessor& p)
    : AudioProcessorEditor (&p), audioProcessor (p)
{
    // Editor's size
    setSize (700, 200);
    
    // Grain Size Slider
    grainSizeSlider.setSliderStyle(juce::Slider::RotaryVerticalDrag);
    grainSizeSlider.setTextBoxStyle(juce::Slider::TextBoxBelow, false, 80, 20);
    grainSizeSlider.setTooltip("Controls the size of each grain in milliseconds");
    addAndMakeVisible(grainSizeSlider);
    
    grainSizeLabel.setText("Grain Size", juce::dontSendNotification);
    grainSizeLabel.setJustificationType(juce::Justification::centred);
    addAndMakeVisible(grainSizeLabel);
    
    grainSizeAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(
        audioProcessor.apvts, "grainSize", grainSizeSlider);
    
    // Pitch Shift Slider
    pitchShiftSlider.setSliderStyle(juce::Slider::RotaryVerticalDrag);
    pitchShiftSlider.setTextBoxStyle(juce::Slider::TextBoxBelow, false, 80, 20);
    pitchShiftSlider.setTooltip("Shifts the pitch of grains without affecting playback speed");
    addAndMakeVisible(pitchShiftSlider);
    
    pitchShiftLabel.setText("Pitch Shift", juce::dontSendNotification);
    pitchShiftLabel.setJustificationType(juce::Justification::centred);
    addAndMakeVisible(pitchShiftLabel);
    
    pitchShiftAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(
        audioProcessor.apvts, "pitchShift", pitchShiftSlider);
    
    // Randomization Slider
    randomizationSlider.setSliderStyle(juce::Slider::RotaryVerticalDrag);
    randomizationSlider.setTextBoxStyle(juce::Slider::TextBoxBelow, false, 80, 20);
    randomizationSlider.setTooltip("Controls the amount of randomization applied to grain positions");
    addAndMakeVisible(randomizationSlider);
    
    randomizationLabel.setText("Randomization", juce::dontSendNotification);
    randomizationLabel.setJustificationType(juce::Justification::centred);
    addAndMakeVisible(randomizationLabel);
    
    randomizationAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(
        audioProcessor.apvts, "randomization", randomizationSlider);
    
    // Dry / Wet Slider
    dryWetSlider.setSliderStyle(juce::Slider::LinearHorizontal);
    dryWetSlider.setTextBoxStyle(juce::Slider::TextBoxRight, false, 60, 20);
    dryWetSlider.setTooltip("Controls the balance between dry (original) and wet (processed) signal");
    addAndMakeVisible(dryWetSlider);
    
    dryWetLabel.setText("Dry/Wet", juce::dontSendNotification);
    dryWetLabel.setJustificationType(juce::Justification::centredLeft);
    addAndMakeVisible(dryWetLabel);
    
    dryWetAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(
        audioProcessor.apvts, "dryWet", dryWetSlider);
    
    // Density Slider
    densitySlider.setSliderStyle(juce::Slider::RotaryVerticalDrag);
    densitySlider.setTextBoxStyle(juce::Slider::TextBoxBelow, false, 80, 20);
    densitySlider.setTooltip("Controls how densely packed the grains are (affects overlap)");
    addAndMakeVisible(densitySlider);
    
    densityLabel.setText("Density", juce::dontSendNotification);
    densityLabel.setJustificationType(juce::Justification::centred);
    addAndMakeVisible(densityLabel);
    
    densityAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(
        audioProcessor.apvts, "density", densitySlider);
    
    // Time Stretch Slider
    timeStretchSlider.setSliderStyle(juce::Slider::RotaryVerticalDrag);
    timeStretchSlider.setTextBoxStyle(juce::Slider::TextBoxBelow, false, 80, 20);
    timeStretchSlider.setTooltip("Controls the playback speed without affecting pitch (0.5x = half speed, 2.0x = double speed)");
    addAndMakeVisible(timeStretchSlider);
    
    timeStretchLabel.setText("Time Stretch", juce::dontSendNotification);
    timeStretchLabel.setJustificationType(juce::Justification::centred);
    addAndMakeVisible(timeStretchLabel);
    
    timeStretchAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(
        audioProcessor.apvts, "timeStretch", timeStretchSlider);
}

GranularSynthVSTAudioProcessorEditor::~GranularSynthVSTAudioProcessorEditor()
{
}

void GranularSynthVSTAudioProcessorEditor::paint (juce::Graphics& g)
{
    // Fill the background
    g.fillAll (juce::Colours::darkgrey.darker(0.8f));
    
    // Draw a border around the plugin
    g.setColour(juce::Colours::white.withAlpha(0.5f));
    g.drawRect(getLocalBounds(), 1);
    
    // Title
    g.setColour(juce::Colours::white);
    g.setFont(20.0f);
    g.drawText("Granular Synth", getLocalBounds().withHeight(30), juce::Justification::centred);
}

void GranularSynthVSTAudioProcessorEditor::resized()
{
    auto area = getLocalBounds();
    
    // Title area
    area.removeFromTop(30);
    
    // Rotary controls (single row)
    auto topArea = area.removeFromTop(130);
    
    // Divide top area into five parts with reduced spacing
    auto grainSizeArea = topArea.removeFromLeft(topArea.getWidth() / 5).reduced(5, 0);
    grainSizeLabel.setBounds(grainSizeArea.removeFromTop(20));
    grainSizeSlider.setBounds(grainSizeArea.reduced(5));
    
    auto pitchShiftArea = topArea.removeFromLeft(topArea.getWidth() / 4).reduced(5, 0);
    pitchShiftLabel.setBounds(pitchShiftArea.removeFromTop(20));
    pitchShiftSlider.setBounds(pitchShiftArea.reduced(5));
    
    auto randomizationArea = topArea.removeFromLeft(topArea.getWidth() / 3).reduced(5, 0);
    randomizationLabel.setBounds(randomizationArea.removeFromTop(20));
    randomizationSlider.setBounds(randomizationArea.reduced(5));
    
    auto densityArea = topArea.removeFromLeft(topArea.getWidth() / 2).reduced(5, 0);
    densityLabel.setBounds(densityArea.removeFromTop(20));
    densitySlider.setBounds(densityArea.reduced(5));
    
    auto timeStretchArea = topArea.reduced(5, 0); // Last remaining part
    timeStretchLabel.setBounds(timeStretchArea.removeFromTop(20));
    timeStretchSlider.setBounds(timeStretchArea.reduced(5));
    
    // Linear slider (bottom area)
    area.removeFromTop(10); // spacing
    
    auto dryWetArea = area.removeFromTop(50);
    auto dryWetLabelArea = dryWetArea.removeFromLeft(80);
    dryWetLabel.setBounds(dryWetLabelArea.reduced(10, 0));
    dryWetSlider.setBounds(dryWetArea.reduced(10, 5));
}