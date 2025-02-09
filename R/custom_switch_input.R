
# By Claude

# Unfortunately it looks like there are still some issues - like not all the CSS
# is working, and the labels aren't vertically centered. But - close enough for
# now!

# TODO

slidingSwitchInput <- function(inputId, label = NULL, 
                               leftLabel = "Left", 
                               rightLabel = "Right",
                               leftValue = leftLabel, 
                               rightValue = rightLabel,
                               selected = leftValue,
                               width = NULL) {
  
  tagList(
    tags$head(
      tags$style(HTML(sprintf("
        .sliding-switch-wrapper {
          display: flex;
          align-items: center;  /* This centers items vertically */
          gap: 10px;
        }
        
        .sliding-switch-container {
          position: relative;
          display: inline-block;
          width: 60px;
          height: 34px;
        }
        
        .sliding-switch-container input {
          opacity: 0;
          width: 0;
          height: 0;
        }
        
        .sliding-switch {
          position: relative;
          cursor: pointer;
          width: 100%%;
          height: 100%%;
          background-color: #e9ecef;
          border-radius: 17px;
          transition: .4s;
        }
        
        .sliding-switch:before {
          position: absolute;
          content: '';
          height: 26px;
          width: 26px;
          left: 4px;
          bottom: 4px;
          background-color: white;
          border-radius: 50%%;
          transition: .4s;
          z-index: 2;
        }
        
        input:checked + .sliding-switch:before {
          transform: translateX(26px);
        }
        
        .external-label {
          font-size: 14px;
          font-weight: 500;
          color: #495057;
          cursor: pointer;
          margin: 0;  /* Remove any default margins */
          padding: 0; /* Remove any default padding */
          line-height: 34px;  /* Match the height of the switch */
        }
        
        input:checked ~ .right-label {
          color: #495057;
        }
        
        input:not(:checked) ~ .left-label {
          color: #495057;
        }
      ")))
    ),
    
    # Input label if provided
    if (!is.null(label)) tags$label(label),
    
    # Wrapper for switch and labels
    tags$div(
      class = "sliding-switch-wrapper",
      style = if (!is.null(width)) paste0("width: ", width),
      
      # Left label
      tags$label(
        class = "external-label left-label",
        `for` = inputId,
        leftLabel,
        `data-value` = leftValue  # Store the value as a data attribute
      ),
      
      # The switch container
      tags$div(
        class = "sliding-switch-container",
        
        tags$input(
          id = inputId,
          type = "checkbox",
          checked = if(selected == rightValue) "checked"
        ),
        
        tags$label(
          class = "sliding-switch",
          `for` = inputId
        )
      ),
      
      # Right label
      tags$label(
        class = "external-label right-label",
        `for` = inputId,
        rightLabel,
        `data-value` = rightValue  # Store the value as a data attribute
      )
    )
  )
}

# Updated JavaScript binding to use data-value attributes
slidingSwitchBinding <- HTML("
var slidingSwitchBinding = new Shiny.InputBinding();

$.extend(slidingSwitchBinding, {
  find: function(scope) {
    return $(scope).find('.sliding-switch-container input');
  },
  getValue: function(el) {
    var $wrapper = $(el).closest('.sliding-switch-wrapper');
    var isChecked = $(el).prop('checked');
    var leftValue = $wrapper.find('.left-label').attr('data-value');
    var rightValue = $wrapper.find('.right-label').attr('data-value');
    return isChecked ? rightValue : leftValue;
  },
  setValue: function(el, value) {
    $(el).prop('checked', value);
  },
  subscribe: function(el, callback) {
    $(el).on('change.slidingSwitchBinding', function(e) {
      callback();
    });
  },
  unsubscribe: function(el) {
    $(el).off('.slidingSwitchBinding');
  }
});

Shiny.inputBindings.register(slidingSwitchBinding);
")
