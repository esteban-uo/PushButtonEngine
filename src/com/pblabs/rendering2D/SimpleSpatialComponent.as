/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 * 
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.pblabs.rendering2D
{
   import com.pblabs.engine.entity.EntityComponent;
   import com.pblabs.engine.core.*;
   import com.pblabs.engine.components.*;
   
   import flash.geom.Point;
   import flash.geom.Rectangle;

   /**
    * Very basic spatial component that exists at a position. Velocity can be
    * applied, but no physical simulation is done.
    */ 
   public class SimpleSpatialComponent extends TickedComponent implements ISpatialObject2D
   {
      /**
       * The spatial manager this object belongs to.
       */
      [EditorData(referenceType="componentReference")]
      public function get spatialManager():ISpatialManager2D
      {
         return _spatialManager;
      }
      
      public function set spatialManager(value:ISpatialManager2D):void
      {
         if (!isRegistered)
         {
            _spatialManager = value;
            return;
         }
         
         if (_spatialManager)
            _spatialManager.removeSpatialObject(this);
         
         _spatialManager = value;
         
         if (_spatialManager)
            _spatialManager.addSpatialObject(this);
      }
      
      /**
       * If set, a SpriteRenderComponent we can use to fulfill point occupied
       * tests.
       */
      public var spriteForPointChecks:SpriteRenderComponent;
      
      /**
       * The position of the object.
       */
      public var position:Point = new Point(0, 0);
      
      /**
       * The rotation of the object.
       */
      public var rotation:Number = 0;
      
      /**
       * The size of the object.
       */
      [EditorData(defaultValue="100|100")]
      public var size:Point = new Point(100, 100);
      
      /**
       * The linear velocity of the object in world units per second.
       */
      public var velocity:Point = new Point(0, 0);
      
      /**
       * @inheritDoc
       */
      override public function onTick(tickRate:Number):void
      {
         position.x += velocity.x * tickRate;
         position.y += velocity.y * tickRate;
      }
      
      /**
       * @inheritDoc
       */
      override protected function onAdd():void
      {
         super.onAdd();
         
         if (_spatialManager)
            _spatialManager.addSpatialObject(this);
      }
      
      /**
       * @inheritDoc
       */
      override protected function onRemove():void
      {
         super.onRemove();

         if (_spatialManager)
            _spatialManager.removeSpatialObject(this);
      }
      
      /**
       * @inheritDoc
       */
      public function get objectMask():ObjectType
      {
         return _objectMask;
      }
      
      /**
       * @private
       */
      public function set objectMask(value:ObjectType):void
      {
         _objectMask = value;
      }
      
      /**
       * @inheritDoc
       */
      public function get worldExtents():Rectangle
      {
         return new Rectangle(position.x - (size.x * 0.5), position.y - (size.y * 0.5), size.x, size.y);         
      }
      
      /**
       * Not currently implemented.
       * @inheritDoc
       */
      public function castRay(start:Point, end:Point, mask:ObjectType, info:RayHitInfo):Boolean
      {
         return false;
      }

      /**
       * All points in our bounding box are occupied.
       * @inheritDoc
       */
      public function pointOccupied(pos:Point, scene:IDrawManager2D):Boolean
      {
         // If no sprite then we just test our bounds.
         if(!spriteForPointChecks || !scene)
            return worldExtents.containsPoint(pos);
         
         // OK, so pass it over to the sprite.
         return spriteForPointChecks.pointOccupied(pos, scene);
      }
      
      private var _objectMask:ObjectType;
      private var _spatialManager:ISpatialManager2D;
   }
}