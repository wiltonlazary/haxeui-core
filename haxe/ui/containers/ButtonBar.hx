package haxe.ui.containers;

import haxe.ui.behaviours.DataBehaviour;
import haxe.ui.behaviours.DefaultBehaviour;
import haxe.ui.components.Button;
import haxe.ui.containers.Box;
import haxe.ui.core.Component;
import haxe.ui.core.CompositeBuilder;
import haxe.ui.core.IDirectionalComponent;
import haxe.ui.events.UIEvent;
import haxe.ui.layouts.LayoutFactory;
import haxe.ui.styles.Style;
import haxe.ui.util.Variant;

@:composite(Events, Builder)
class ButtonBar extends Box implements IDirectionalComponent {
    @:clonable @:behaviour(DefaultBehaviour, true)      public var toggle:Bool;
    @:clonable @:behaviour(SelectedIndex)               public var selectedIndex:Int;
    @:clonable @:behaviour(SelectedButton)              public var selectedButton:Component;
    @:clonable @:value(selectedIndex)                   public var value:Dynamic;
}

//***********************************************************************************************************
// Behaviours
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
@:access(haxe.ui.containers.Builder)
private class SelectedIndex extends DataBehaviour {
    private override function validateData() {
        var builder:Builder = cast(_component._compositeBuilder, Builder);
        var currentButton = builder._currentButton;
        var button = cast(_component.getComponentAt(_value), Button);
        if (currentButton == button) {
            return;
        }
        
        if (currentButton != null) {
            builder._currentButton.selected = false;
        }
        
        button.selected = true;
        builder._currentButton = button;
        
        _component.dispatch(new UIEvent(UIEvent.CHANGE));
    }
}

@:dox(hide) @:noCompletion
private class SelectedButton extends DataBehaviour {
    public override function get():Variant {
        for (child in _component.childComponents) {
            if ((child is Button) && cast(child, Button).selected == true) {
                return child;
            }
        }
        return null;
    }
}

//***********************************************************************************************************
// Events
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Events extends haxe.ui.events.Events {
    private var _bar:ButtonBar;

    private function new(bar:ButtonBar) {
        super(bar);
        _bar = bar;
    }
    
    public override function register() {
        var buttons = _target.findComponents(Button, 1);
        for (button in buttons) {
            if (button.hasEvent(UIEvent.CHANGE, onButtonChanged) == false) {
                button.registerEvent(UIEvent.CHANGE, onButtonChanged);
            }
        }
    }

    public override function unregister() {
        var buttons = _target.findComponents(Button, 1);
        for (button in buttons) {
            button.unregisterEvent(UIEvent.CHANGE, onButtonChanged);
        }
    }

    private function onButtonChanged(event:UIEvent) {
        var button = cast(event.target, Button);
        var index = _bar.getComponentIndex(button);
        if (index == _bar.selectedIndex && button.selected == false) {
            button.selected = true;
            return;
        }
        if (button.selected == true) {
            _bar.selectedIndex = index;
        }
    }
}

//***********************************************************************************************************
// Composite Builder
//***********************************************************************************************************
@:dox(hide) @:noCompletion
@:access(haxe.ui.core.Component)
private class Builder extends CompositeBuilder {
    private var _bar:ButtonBar;
    private var _currentButton:Button;
    
    private function new(bar:ButtonBar) {
        super(bar);
        _bar = bar;
    }
    
    public override function addComponent(child:Component):Component {
        if ((child is Button)) {
            cast(child, Button).toggle = _bar.toggle;
        }
        
        _component.registerInternalEvents(true);
        
        return null;
    }
    
    public override function onReady() {
        _component.registerInternalEvents(true);
    }
    
    public override function applyStyle(style:Style) {
        if (style.direction != null) {
            var direction = style.direction;
            if (direction == "vertical") {
                _component.swapClass("vertical-button-bar", "horizontal-button-bar");
            } else if (direction == "horizontal") {
                _component.swapClass("horizontal-button-bar", "vertical-button-bar");
            }
            _component.layout = LayoutFactory.createFromName(direction);
        }
    }
}