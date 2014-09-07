package com.xtend.coap.resource;

import com.google.common.base.Objects;
import com.xtend.coap.message.request.DeleteRequest;
import com.xtend.coap.message.request.GetRequest;
import com.xtend.coap.message.request.PostRequest;
import com.xtend.coap.message.request.PutRequest;
import com.xtend.coap.message.request.RequestHandler;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.StringTokenizer;
import java.util.TreeMap;
import org.eclipse.xtext.xbase.lib.Exceptions;

/**
 * Class that represents a Resource.
 * 
 * @author César Estebas Gómez.
 * @version Xtend-CoAP_v1.0.
 */
@SuppressWarnings("all")
public class Resource implements RequestHandler {
  protected Resource parent;
  
  protected Map<String, Resource> subResources;
  
  private int totalSubResourceCount;
  
  private String resourceIdentifier;
  
  private String resourceName;
  
  private String interfaceDescription;
  
  private int contentTypeCode;
  
  private int maximumSizeEstimate;
  
  private boolean observable;
  
  private boolean hidden;
  
  /**
   * Constructor for a Resource object.
   */
  public Resource() {
    this(null);
  }
  
  /**
   * Constructor for a Resource object.
   * 
   * @param resourceIdentifier The resource identifier.
   */
  public Resource(final String resourceIdentifier) {
    this(resourceIdentifier, false);
  }
  
  /**
   * Constructor for a Resource object.
   * 
   * @param resourceIdentifier The resource identifier.
   * @param hidden If its true, the recurse is hidden.
   */
  public Resource(final String resourceIdentifier, final boolean hidden) {
    this.resourceIdentifier = resourceIdentifier;
    this.resourceName = "";
    this.interfaceDescription = "";
    this.contentTypeCode = (-1);
    this.maximumSizeEstimate = (-1);
    this.observable = false;
    this.hidden = hidden;
  }
  
  /**
   * This method sets an extension attribute given in a string of the form
   * "...=..."
   * 
   * @param linkExtension The link extension string specifying a link
   *                      extension and a value for it
   */
  public void populateAttributeFromLinkExtension(final String linkExtension) {
    String[] elements = linkExtension.split("=");
    String ext = elements[0];
    String value = elements[1];
    boolean _equals = ext.equals("n");
    if (_equals) {
      int _length = value.length();
      int _minus = (_length - 1);
      String _substring = value.substring(1, _minus);
      this.setResourceName(_substring);
    } else {
      boolean _equals_1 = ext.equals("d");
      if (_equals_1) {
        int _length_1 = value.length();
        int _minus_1 = (_length_1 - 1);
        String _substring_1 = value.substring(1, _minus_1);
        this.setInterfaceDescription(_substring_1);
      } else {
        boolean _equals_2 = ext.equals("ct");
        if (_equals_2) {
          int _parseInt = Integer.parseInt(value);
          this.setContentTypeCode(_parseInt);
        } else {
          boolean _equals_3 = ext.equals("sz");
          if (_equals_3) {
            int _parseInt_1 = Integer.parseInt(value);
            this.setMaximumSizeEstimate(_parseInt_1);
          } else {
            boolean _equals_4 = ext.equals("obs");
            if (_equals_4) {
              boolean _parseBoolean = Boolean.parseBoolean(value);
              this.setObservable(_parseBoolean);
            }
          }
        }
      }
    }
  }
  
  /**
   * This method sets the resource identifier of the current resource
   * 
   * @param resourceURI The resource identifier
   */
  public void setResourceIdentifier(final String resourceIdentifier) {
    this.resourceIdentifier = resourceIdentifier;
  }
  
  /**
   * This method sets the resource name of the current resource
   * 
   * @param resourceName The resource name
   */
  public void setResourceName(final String resourceName) {
    this.resourceName = resourceName;
  }
  
  /**
   * This method sets the interface description of the current resource
   * 
   * @param interfaceDescription The resource interface description
   */
  public void setInterfaceDescription(final String interfaceDescription) {
    this.interfaceDescription = interfaceDescription;
  }
  
  /**
   * This method sets the content type code of the current resource
   * 
   * @param contentTypeCode The resource contentTypeCode
   */
  public void setContentTypeCode(final int contentTypeCode) {
    this.contentTypeCode = contentTypeCode;
  }
  
  /**
   * This method sets the maximum size estimate of the current resource
   * 
   * @param maximumSizeExtimate The resource maximum size estimate
   */
  public void setMaximumSizeEstimate(final int maximumSizeEstimate) {
    this.maximumSizeEstimate = maximumSizeEstimate;
  }
  
  /**
   * This method sets whether the current resource is observable
   * 
   * @param observable The boolean value whether the current resource is
   *                   observable
   */
  public void setObservable(final boolean observable) {
    this.observable = observable;
  }
  
  /**
   * This method sets attributes of a given resource according to data from
   * a given link extension string
   * 
   * @param res The resource containing the attributes which should be set
   * @param linkExtension The string with the link extension data
   */
  public static void populateAttributeFromLinkExtension(final Resource res, final String linkExtension) {
    String[] elements = linkExtension.split("=");
    String ext = elements[0];
    String value = new String();
    int _length = elements.length;
    boolean _greaterThan = (_length > 1);
    if (_greaterThan) {
      String _get = elements[1];
      value = _get;
    }
    boolean _equals = ext.equals("n");
    if (_equals) {
      int _length_1 = value.length();
      int _minus = (_length_1 - 1);
      String _substring = value.substring(1, _minus);
      res.setResourceName(_substring);
    } else {
      boolean _equals_1 = ext.equals("d");
      if (_equals_1) {
        int _length_2 = value.length();
        int _minus_1 = (_length_2 - 1);
        String _substring_1 = value.substring(1, _minus_1);
        res.setInterfaceDescription(_substring_1);
      } else {
        boolean _equals_2 = ext.equals("ct");
        if (_equals_2) {
          int _parseInt = Integer.parseInt(value);
          res.setContentTypeCode(_parseInt);
        } else {
          boolean _equals_3 = ext.equals("sz");
          if (_equals_3) {
            int _parseInt_1 = Integer.parseInt(value);
            res.setMaximumSizeEstimate(_parseInt_1);
          } else {
            boolean _equals_4 = ext.equals("obs");
            if (_equals_4) {
              res.setObservable(true);
            }
          }
        }
      }
    }
  }
  
  /**
   * This method returns a resource set from a link format string
   * 
   * @param linkFormatString The link format representation of the resources
   * @return The resource set
   */
  public void addLinkFormat(final String linkFormat) {
    StringTokenizer items = new StringTokenizer(linkFormat, ",");
    boolean _hasMoreTokens = items.hasMoreTokens();
    boolean _while = _hasMoreTokens;
    while (_while) {
      String _nextToken = items.nextToken();
      this.addLinkFormatItem(_nextToken);
      boolean _hasMoreTokens_1 = items.hasMoreTokens();
      _while = _hasMoreTokens_1;
    }
  }
  
  /**
   * This method returns a resource set from a link format item
   * 
   * @param item The link format item.
   * @return The resource set.
   */
  public void addLinkFormatItem(final String item) {
    StringTokenizer tokens = new StringTokenizer(item, ";");
    String identifier = tokens.nextToken();
    int _length = identifier.length();
    int _minus = (_length - 1);
    String _substring = identifier.substring(2, _minus);
    identifier = _substring;
    Resource resource = this.subResource(identifier, true);
    boolean _hasMoreTokens = tokens.hasMoreTokens();
    boolean _while = _hasMoreTokens;
    while (_while) {
      String _nextToken = tokens.nextToken();
      Resource.populateAttributeFromLinkExtension(resource, _nextToken);
      boolean _hasMoreTokens_1 = tokens.hasMoreTokens();
      _while = _hasMoreTokens_1;
    }
  }
  
  /**
   * This method returns a link format string for the current resource
   * 
   * @return The link format string representing the current resource
   */
  public String toLinkFormatItem() {
    StringBuilder linkFormat = new StringBuilder();
    linkFormat.append("<");
    String _resourceIdentifier = this.getResourceIdentifier(true);
    linkFormat.append(_resourceIdentifier);
    linkFormat.append(">;");
    String _resourceName = this.getResourceName();
    boolean _isEmpty = _resourceName.isEmpty();
    boolean _not = (!_isEmpty);
    if (_not) {
      linkFormat.append("n=\"");
      String _resourceName_1 = this.getResourceName();
      linkFormat.append(_resourceName_1);
      linkFormat.append("\";");
    }
    String _interfaceDescription = this.getInterfaceDescription();
    boolean _isEmpty_1 = _interfaceDescription.isEmpty();
    boolean _not_1 = (!_isEmpty_1);
    if (_not_1) {
      linkFormat.append("d=\"");
      String _interfaceDescription_1 = this.getInterfaceDescription();
      linkFormat.append(_interfaceDescription_1);
      linkFormat.append("\";");
    }
    int _contentTypeCode = this.getContentTypeCode();
    boolean _notEquals = (_contentTypeCode != (-1));
    if (_notEquals) {
      linkFormat.append("ct=");
      int _contentTypeCode_1 = this.getContentTypeCode();
      linkFormat.append(_contentTypeCode_1);
      linkFormat.append(";");
    }
    int _maximumSizeEstimate = this.getMaximumSizeEstimate();
    boolean _notEquals_1 = (_maximumSizeEstimate != (-1));
    if (_notEquals_1) {
      linkFormat.append("sz=");
      int _maximumSizeEstimate_1 = this.getMaximumSizeEstimate();
      linkFormat.append(_maximumSizeEstimate_1);
      linkFormat.append(";");
    }
    boolean _isObservable = this.isObservable();
    if (_isObservable) {
      linkFormat.append("obs;");
    }
    int _length = linkFormat.length();
    int _minus = (_length - 1);
    linkFormat.deleteCharAt(_minus);
    return linkFormat.toString();
  }
  
  /**
   * This method returns a link format string for the current sub-resource set
   * 
   * @return The link format string representing the current sub-resource set
   */
  public String toLinkFormat() {
    StringBuilder builder = new StringBuilder();
    this.buildLinkFormat(builder);
    int _length = builder.length();
    int _minus = (_length - 1);
    builder.deleteCharAt(_minus);
    return builder.toString();
  }
  
  /**
   * This method is used to build the link format representation of the resources.
   */
  public void buildLinkFormat(final StringBuilder builder) {
    boolean _notEquals = (!Objects.equal(this.subResources, null));
    if (_notEquals) {
      Collection<Resource> _values = this.subResources.values();
      for (final Resource resource : _values) {
        {
          if ((!resource.hidden)) {
            String _linkFormatItem = resource.toLinkFormatItem();
            builder.append(_linkFormatItem);
            builder.append(",");
          }
          resource.buildLinkFormat(builder);
        }
      }
    }
  }
  
  /**
   * This method returns the resource URI of the current resource.
   * 
   * @return The current resource URI.
   */
  public String getResourceIdentifier(final boolean absolute) {
    boolean _and = false;
    if (!absolute) {
      _and = false;
    } else {
      boolean _notEquals = (!Objects.equal(this.parent, null));
      _and = _notEquals;
    }
    if (_and) {
      StringBuilder builder = new StringBuilder();
      String _resourceIdentifier = this.parent.getResourceIdentifier(absolute);
      builder.append(_resourceIdentifier);
      builder.append("/");
      builder.append(this.resourceIdentifier);
      return builder.toString();
    } else {
      return this.resourceIdentifier;
    }
  }
  
  /**
   * This method returns the resource identifier of the current resource.
   * 
   * @return The current resource identifier.
   */
  public String getResourceIdentifier() {
    return this.getResourceIdentifier(false);
  }
  
  /**
   * This method returns the resource name of the current resource.
   * 
   * @return The current resource name.
   */
  public String getResourceName() {
    return this.resourceName;
  }
  
  /**
   * This method returns the interface description of the current resource.
   * 
   * @return The current resource interface description.
   */
  public String getInterfaceDescription() {
    return this.interfaceDescription;
  }
  
  /**
   * This method returns the content type code of the current resource
   * 
   * @return The current resource content type code
   */
  public int getContentTypeCode() {
    return this.contentTypeCode;
  }
  
  /**
   * This method returns the maximum size estimate of the current resource
   * 
   * @return The current resource maximum size estimate
   */
  public int getMaximumSizeEstimate() {
    return this.maximumSizeEstimate;
  }
  
  /**
   * This method returns whether the current resource is observable or not
   * 
   * @return Boolean value whether the current resource is observable
   */
  public boolean isObservable() {
    return this.observable;
  }
  
  /**
   * This method returns the subresources count of the current resource.
   * 
   * @return The current resource subresources count.
   */
  public int subResourceCount() {
    int res = 0;
    boolean _notEquals = (!Objects.equal(this.subResources, null));
    if (_notEquals) {
      int _size = this.subResources.size();
      res = _size;
    }
    return 0;
  }
  
  public int totalSubResourceCount() {
    return this.totalSubResourceCount;
  }
  
  /**
   * This method returns the subresources count of the current resource.
   * 
   * @param resourceIdentifier The resource identifier.
   * @param create If its true and the resource is null creates the resource.
   * @return The resource identified by the resource identifier.
   */
  public Resource subResource(final String resourceIdentifier, final boolean create) {
    int pos = resourceIdentifier.indexOf("/");
    String head = null;
    String tail = null;
    boolean _and = false;
    if (!(pos != (-1))) {
      _and = false;
    } else {
      int _length = resourceIdentifier.length();
      int _minus = (_length - 1);
      boolean _lessThan = (pos < _minus);
      _and = _lessThan;
    }
    if (_and) {
      String _substring = resourceIdentifier.substring(0, pos);
      head = _substring;
      String _substring_1 = resourceIdentifier.substring((pos + 1));
      tail = _substring_1;
    } else {
      head = resourceIdentifier;
      tail = null;
    }
    Resource resource = null;
    boolean _notEquals = (!Objects.equal(this.subResources, null));
    if (_notEquals) {
      Resource _get = this.subResources.get(head);
      resource = _get;
    }
    boolean _and_1 = false;
    boolean _equals = Objects.equal(resource, null);
    if (!_equals) {
      _and_1 = false;
    } else {
      _and_1 = create;
    }
    if (_and_1) {
      try {
        Class<? extends Resource> _class = this.getClass();
        Resource _newInstance = _class.newInstance();
        resource = _newInstance;
        resource.setResourceIdentifier(head);
        this.addSubResource(resource);
      } catch (final Throwable _t) {
        if (_t instanceof InstantiationException) {
          final InstantiationException e = (InstantiationException)_t;
          e.printStackTrace();
        } else if (_t instanceof IllegalAccessException) {
          final IllegalAccessException e_1 = (IllegalAccessException)_t;
          e_1.printStackTrace();
        } else {
          throw Exceptions.sneakyThrow(_t);
        }
      }
    }
    boolean _and_2 = false;
    boolean _notEquals_1 = (!Objects.equal(resource, null));
    if (!_notEquals_1) {
      _and_2 = false;
    } else {
      boolean _notEquals_2 = (!Objects.equal(tail, null));
      _and_2 = _notEquals_2;
    }
    if (_and_2) {
      return resource.subResource(tail, create);
    } else {
      return resource;
    }
  }
  
  public Resource subResource(final String resourceIdentifier) {
    return this.subResource(resourceIdentifier, false);
  }
  
  public Resource getResource(final String resourceIdentifier) {
    int pos = resourceIdentifier.indexOf("/");
    String head = null;
    String tail = null;
    boolean _and = false;
    if (!(pos != (-1))) {
      _and = false;
    } else {
      int _length = resourceIdentifier.length();
      int _minus = (_length - 1);
      boolean _lessThan = (pos < _minus);
      _and = _lessThan;
    }
    if (_and) {
      String _substring = resourceIdentifier.substring(0, pos);
      head = _substring;
      String _substring_1 = resourceIdentifier.substring((pos + 1));
      tail = _substring_1;
    } else {
      head = resourceIdentifier;
      tail = null;
    }
    boolean _equals = head.equals(this.resourceIdentifier);
    if (_equals) {
      boolean _notEquals = (!Objects.equal(tail, null));
      if (_notEquals) {
        return this.subResource(tail);
      } else {
        return this;
      }
    } else {
      return null;
    }
  }
  
  public Resource[] getSubResources() {
    Resource[] resources = null;
    boolean _notEquals = (!Objects.equal(this.subResources, null));
    if (_notEquals) {
      ArrayList<Resource> al = new ArrayList<Resource>();
      for (int i = 0; (i < this.subResources.size()); i++) {
        al.add(null);
      }
      Object[] _array = al.toArray();
      resources = ((Resource[]) _array);
    } else {
      ArrayList<Resource> _arrayList = new ArrayList<Resource>(0);
      Object[] _array_1 = _arrayList.toArray();
      return ((Resource[]) _array_1);
    }
    Set<Map.Entry<String, Resource>> content = this.subResources.entrySet();
    Iterator<Map.Entry<String, Resource>> iter = content.iterator();
    int pos = 0;
    boolean _hasNext = iter.hasNext();
    boolean _while = _hasNext;
    while (_while) {
      {
        Map.Entry<String, Resource> currentEntry = iter.next();
        Resource _value = currentEntry.getValue();
        resources[pos] = _value;
        pos++;
      }
      boolean _hasNext_1 = iter.hasNext();
      _while = _hasNext_1;
    }
    return resources;
  }
  
  public void addSubResource(final Resource resource) {
    boolean _notEquals = (!Objects.equal(resource, null));
    if (_notEquals) {
      boolean _equals = Objects.equal(this.subResources, null);
      if (_equals) {
        TreeMap<String, Resource> _treeMap = new TreeMap<String, Resource>();
        this.subResources = _treeMap;
      }
      this.subResources.put(resource.resourceIdentifier, resource);
      resource.parent = this;
      Resource p = resource.parent;
      boolean _notEquals_1 = (!Objects.equal(p, null));
      boolean _while = _notEquals_1;
      while (_while) {
        {
          p.totalSubResourceCount++;
          p = p.parent;
        }
        boolean _notEquals_2 = (!Objects.equal(p, null));
        _while = _notEquals_2;
      }
    }
  }
  
  public void removeSubResource(final Resource resource) {
    boolean _notEquals = (!Objects.equal(resource, null));
    if (_notEquals) {
      this.subResources.remove(resource.resourceIdentifier);
      Resource p = resource.parent;
      boolean _notEquals_1 = (!Objects.equal(p, null));
      boolean _while = _notEquals_1;
      while (_while) {
        {
          p.totalSubResourceCount--;
          p = p.parent;
        }
        boolean _notEquals_2 = (!Objects.equal(p, null));
        _while = _notEquals_2;
      }
      resource.parent = null;
    }
  }
  
  public void remove() {
    boolean _notEquals = (!Objects.equal(this.parent, null));
    if (_notEquals) {
      this.parent.removeSubResource(this);
    }
  }
  
  public void removeSubResource(final String resourceIdentifier) {
    Resource _subResource = this.subResource(resourceIdentifier);
    this.removeSubResource(_subResource);
  }
  
  public static Resource newRoot(final String linkFormat) {
    Resource resource = new Resource();
    resource.setResourceIdentifier("");
    resource.setResourceName("root");
    resource.addLinkFormat(linkFormat);
    return resource;
  }
  
  public void log(final PrintStream out, final int intend) {
    for (int i = 0; (i < intend); i++) {
      out.append(" ");
    }
    out.println(((("+[" + this.resourceIdentifier) + "] ") + this.resourceName));
    boolean _notEquals = (!Objects.equal(this.subResources, null));
    if (_notEquals) {
      Collection<Resource> _values = this.subResources.values();
      for (final Resource sub : _values) {
        sub.log(out, (intend + 2));
      }
    }
  }
  
  public void log() {
    this.log(System.out, 0);
  }
  
  public void createNew(final PutRequest request, final String newIdentifier) {
  }
  
  public void performGet(final GetRequest request) {
  }
  
  public void performPost(final PostRequest request) {
  }
  
  public void performPut(final PutRequest request) {
  }
  
  public void performDelete(final DeleteRequest request) {
  }
}
