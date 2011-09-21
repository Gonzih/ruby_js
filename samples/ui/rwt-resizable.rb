if __FILE__ == $0
  p Dir.getwd
  $: << Dir.getwd
  require 'rwt2'
end

module Rwt
  STYLE::RESIZABLE = STYLE::BOTTOM*2
  
  class SizeGripBox < HBox
    def initialize sizee
      @sizee = sizee
      super sizee.ownerDocument.body,:size=>[0,0],:style=>STYLE::FIXED
    end
    
    def show
      super
      x = @sizee.offsetLeft
      y = @sizee.offsetTop
      y = y + @sizee.get_css_style("height").to_f - clientHeight
      set_position [x,y]
      
      w = @sizee.get_css_style("width").to_f
      set_size [w,0]
    end
  end
  
  module Resizable
    def set_style flags=0
      super
      if flags&STYLE::RESIZABLE == STYLE::RESIZABLE
        style['overflow']='hidden'
        make_resizable
      end
    end

    def make_hint
      hint=Rwt::Drawable.new(self.parent,:style=>STYLE::BORDER_ROUND)
      hint.style['z-index']=100
      hint.style['position']="absolute"
      hint.style['border-style']="dashed"
      hint.style.cursor = 'se-resize'
      hint.hide 
      hint
    end
    
    def make_resizable
      return @_grip_box if is_resizable?
      @_grip_box = Rwt::SizeGripBox.new(self)
      @_grip_box.add Rwt::Drawable.new(@_grip_box,:size=>[1,0]),1
      @_grip_box.add @_size_grip=o=Rwt::Drawable.new(@_grip_box,:size=>[0,0]),0
      
      @_is_resizable = true
      
      @_size_hint = make_hint
      
      Rwt::UI::DragHandler.attach(o)
     
      o.style.cssText=o.style.cssText+"""
        border-bottom: 20px solid silver; 
        border-left: 20px solid transparent;
        cursor: se-resize;  
        z-index: 10000;
      """      
      
      o.dragBegin = proc do
        @_size_hint.show
        @_size_hint.set_size self.get_size
        @_size_hint.set_position [self.offsetLeft,self.offsetTop]
        Rwt::UI::DragHandler.of(o).native.grip = Rwt::UI::DragHandler.of(o).dragged = @_size_hint.element
        o.ownerDocument.body.style.cursor = 'se-resize'
        true
      end
      
      @_size_hint.dragBegin = proc do 
        true
      end
      
      @_size_hint.dragEnd = proc do
        @_size_hint.hide
        Rwt::UI::DragHandler.of(@_size_hint).grip = Rwt::UI::DragHandler.of(@_size_hint).dragged = o.element
        on_resize(@_size_hint.get_size)
        true
      end
      
      @_size_hint.drag = JS.execute_script(context,"""
        f=function(g,nx,ny,cx,cy) {
          this.style.width = (parseInt(this.style.width)+cx)+'px';
          this.style.height = (parseInt(this.style.height)+cy)+'px';
          return false;
        };
        f;
      """)
    end
    
    def is_resizable?
      @_is_resizable
    end
    
    def show
      r=super
      @_grip_box.show
      r
    end
    
    # Just resize the object
    # children/contents resizing should be implemented in the class implemeting this module
    # If the implementing instance is a subclass of Rwt::Box, content resizing should be automatic
    #   (the preffered way)
    def on_resize size
      set_size size
      @_grip_box.show
    end
    
    def self.extended q
      q.set_style q.instance_variable_get("@_style")|STYLE::RESIZABLE
    end
  end    
end

if __FILE__ == $0
  require 'demo_common'
  
  STYLE = Rwt::STYLE 
  
  Examples = [
    "Extend a Drawable to become Resizable",
    "Extend a Container to become Resizable",
    "Implement a Resizable Container Class",
    "Using Box's to simplify children resizing",
    "Implement a Resizable Box Class"
  ]
  
  def example1 document
    root ,window = base(document,1)
    
    r=Rwt::Drawable.new(root.find(:test)[0],:size=>[200,300],:style=>STYLE::FIXED|STYLE::CENTER|STYLE::BORDER_ROUND|STYLE::FLAT)
    r.innerText="Drag the lower right corner to resize ..."
    
    r.extend Rwt::Resizable
    r.show
  end  
  
  def example2 document
    root,window = base(document,2)
    
    r=Rwt::Container.new(root.find(:test)[0],:size=>[200,300],:style=>STYLE::FIXED|STYLE::CENTER|STYLE::BORDER_ROUND|STYLE::FLAT)
    r.extend Rwt::Resizable
    r.add Rwt::Button.new(r,'This button will expand with the container')
    
    def r.on_resize *o
      super
      children.each do |c| c.show end
    end
    
    r.show
  end
  
  class ImplementsResize < Rwt::Container
    include Rwt::Resizable
    def on_resize size
      super
      children.each do |c| c.show end
    end
  end
  
  def example3 document
    root,window = base(document,3)
    
    r=ImplementsResize.new(root.find(:test)[0],:size=>[200,300],:style=>STYLE::FIXED|STYLE::CENTER|STYLE::BORDER_ROUND|STYLE::FLAT|STYLE::RESIZABLE)
    
    r.add Rwt::Button.new(r,'This button will expand with the container')
    r.show
  end  
  
  def example4 document
    root,window = base(document,4)
    
    r=Rwt::VBox.new(root.find(:test)[0],:size=>[200,300],:style=>STYLE::FIXED|STYLE::CENTER|STYLE::BORDER_ROUND|STYLE::FLAT)
   
    r.extend Rwt::Resizable
    r.add Rwt::Button.new(r,'This button will expand with the container',:size=>[1,1]),1,true    
    r.show
  end  
  
  class VBoxResize < Rwt::VBox
    include Rwt::Resizable
  end
  
  def example5 document
    root,window = base(document,5)
    
    r=VBoxResize.new(root.find(:test)[0],:size=>[200,300],:style=>STYLE::FIXED|STYLE::CENTER|STYLE::BORDER_ROUND|STYLE::FLAT|STYLE::RESIZABLE)
   
    r.add Rwt::Button.new(r,'This button will expand with the container',:size=>[1,1]),1,true    
    r.show
  end   
  
  launch
end
